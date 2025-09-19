import Foundation
import CoreData
import Combine
import ActivityKit // 1. Import ActivityKit

enum LiveRunState {
    case inactive
    case running
    case paused
}

class LiveTrackingViewModel: ObservableObject {
    @Published var runState: LiveRunState = .inactive
    @Published var elapsedTime: TimeInterval = 0
    @Published var activeLog: Log?
    @Published var nextSplitIndex: Int = 1
    @Published var splitTime: TimeInterval = 0
    @Published var numPins: Int = 1
    
    private var timer: Timer?
    private var startTime: Date?
    private var currentTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var viewContext: NSManagedObjectContext
    private var lastTime: Date?
    
    private var runActivity: Activity<TgoActivityAttributes>?
    
    private var locationManager: LocationManager

//    init(context: NSManagedObjectContext) {
//        self.viewContext = context
//    }
    init(context: NSManagedObjectContext, locationManager: LocationManager) {
            self.viewContext = context
            self.locationManager = locationManager
            
            // Set up the callbacks right here
            setupLocationManagerCallbacks()
        }
    private func setupLocationManagerCallbacks() {
            locationManager.onRegionEnter = { [weak self] region in
                self?.handleRegionTrigger(identifier: region.identifier)
            }
            locationManager.onRegionExit = { [weak self] region in
                self?.handleRegionTrigger(identifier: region.identifier)
            }
        }
    
    func startRun(for route: Route) {
        print(route.name ?? "Unnamed Route")
        let routePins = route.routePins as? Set<RoutePin> ?? []
        // Get the sorted RoutePin objects, not just the Pins
        let sortedRoutePins = routePins.sorted { $0.order < $1.order }
        
        guard !sortedRoutePins.isEmpty else { return }
        
        let newLog = Log(context: viewContext)
        newLog.id = UUID()
        newLog.startTime = Date()
        newLog.route = route
        
        // Iterate over the RoutePins to access displayName
        for routePin in sortedRoutePins {
            let loggedPin = LoggedPin(context: viewContext)
            loggedPin.id = UUID()
            loggedPin.pin = routePin.pin
            loggedPin.log = newLog
            loggedPin.order = routePin.order
            
            loggedPin.displayName = routePin.displayName
            
            if routePin.order == 0 {
                loggedPin.runningTime = 0
                loggedPin.splitTime = 0
            }
        }
        
        self.activeLog = newLog
        self.nextSplitIndex = 1
        
        accumulatedTime = 0
        startTime = Date()
        startTimer()
        splitTimer()
        runState = .running
        lastTime = Date()
        
        guard let log = activeLog else { return }
        
        let loggedPinsSet = log.loggedPins as? Set<LoggedPin> ?? []
        let loggedPins = loggedPinsSet.sorted { $0.order < $1.order }
        numPins = loggedPins.count - 1
        
        startLiveActivity(sortedRoutePins: sortedRoutePins)
    }
    
    func splitLap() {
        guard let log = activeLog else { return }
        
        let loggedPinsSet = log.loggedPins as? Set<LoggedPin> ?? []
        let loggedPins = loggedPinsSet.sorted { $0.order < $1.order }
        
        guard nextSplitIndex < loggedPins.count else { return }
        
        let currentLoggedPin = loggedPins[nextSplitIndex]
        let previousLoggedPin = loggedPins[nextSplitIndex - 1]
        
        let currentTime = currentElapsedTime()
        currentLoggedPin.runningTime = currentTime
        currentLoggedPin.splitTime = currentTime - previousLoggedPin.runningTime
        
        updateLiveActivity(loggedPins: loggedPins, nextIndex: nextSplitIndex + 1)
        
        if nextSplitIndex == loggedPins.count - 1 {
            finishRun()
        } else {
            nextSplitIndex += 1
        }
        splitTimer()
        lastTime = Date()
    }
    
    func finishRun() {
        timer?.invalidate()
        if let log = activeLog {
            log.totalTime = currentElapsedTime()
            do {
                try viewContext.save()
            } catch {
                print("Error saving log: \(error.localizedDescription)")
            }
        }
        endLiveActivity()
        
        reset()
    }
    func pause() {
        timer?.invalidate()
        // Add the time elapsed since the last start/resume to the total.
        accumulatedTime += Date().timeIntervalSince(startTime ?? Date())
        runState = .paused
    }
    
    func resume() {
        startTime = Date() // Reset the start time for the new interval
        runState = .running
        startTimer()
    }
    
//    func handleRegionEntry(identifier: String) {
//            // Parse the order number from an identifier like "pin_1"
//            let components = identifier.split(separator: "_")
//            guard components.count == 2, let order = Int(components[1]) else {
//                print("Invalid region identifier format: \(identifier)")
//                return
//            }
//
//            // Check if the entered region corresponds to the *next expected* checkpoint.
//            if order == nextSplitIndex {
//                print("Correct region entered: \(identifier). Splitting lap.")
//                DispatchQueue.main.async {
//                    self.splitLap()
//                }
//            } else {
//                print("Entered region \(identifier) out of order. Expected index was \(nextSplitIndex).")
//                // This logic prevents splitting if a user passes through a future checkpoint's
//                // region before completing the current one.
//            }
//        }
    func handleRegionTrigger(identifier: String) {
            let components = identifier.split(separator: "_")
            guard components.count == 2, let order = Int(components[1]) else {
                print("Invalid region identifier format: \(identifier)")
                return
            }
        
        let polyline = Polyline.encode(coordinates: locationManager.polylineRoute)
//        print(locationManager.polylineRoute)
//        print(polyline)
        guard let log = activeLog else { return }
        log.polyline = polyline
        if order == nextSplitIndex {
            print("Correct region triggered: \(identifier). Splitting lap.")
                DispatchQueue.main.async {
                    self.splitLap()
                }
            } else {
                print("Region \(identifier) triggered out of order. Expected index was \(nextSplitIndex).")
            }
        }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private func startLiveActivity(sortedRoutePins: [RoutePin]) {
        let attributes = TgoActivityAttributes(routeName: activeLog?.route?.name ?? "My Route")
        let initialState = TgoActivityAttributes.ContentState(
            currentCheckpoint: sortedRoutePins.first?.displayName ?? "Start",
            nextCheckpoint: sortedRoutePins.count > 1 ? sortedRoutePins[1].displayName ?? "Next" : "Finish",
            elapsedTime: "00:00.00"
        )
        
        let activityContent = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            runActivity = try Activity<TgoActivityAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil)
            print("Live Activity started successfully.")
        } catch (let error) {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity(loggedPins: [LoggedPin], nextIndex: Int) {
        let newContentState = TgoActivityAttributes.ContentState(
            currentCheckpoint: loggedPins[nextIndex - 1].displayName ?? "Checkpoint",
            nextCheckpoint: nextIndex < loggedPins.count ? loggedPins[nextIndex].displayName ?? "Next" : "Finish",
            elapsedTime: formatTime(elapsedTime)
        )
        
        Task {
            let activityContent = ActivityContent(state: newContentState, staleDate: nil)
            await runActivity?.update(activityContent)
        }
    }
    
    private func endLiveActivity() {
        Task {
            let finalState = TgoActivityAttributes.ContentState(
                currentCheckpoint: "Finished",
                nextCheckpoint: "",
                elapsedTime: formatTime(elapsedTime)
            )
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            
            await runActivity?.end(finalContent, dismissalPolicy: .immediate)
            print("Live Activity ended.")
        }
    }
    
    private func reset() {
        timer?.invalidate()
        runState = .inactive
        elapsedTime = 0
        accumulatedTime = 0
        activeLog = nil
        nextSplitIndex = 1
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedTime = self?.currentElapsedTime() ?? 0
        }
    }
    
    private func splitTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.splitTime = self?.currentSplitTime() ?? 0
        }
    }
    
    private func currentElapsedTime() -> TimeInterval {
        return accumulatedTime + Date().timeIntervalSince(startTime ?? Date())
    }
    private func currentSplitTime() -> TimeInterval {
        return Date().timeIntervalSince(lastTime ?? Date())
    }
}

