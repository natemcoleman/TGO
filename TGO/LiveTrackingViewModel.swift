import Foundation
import CoreData
import Combine

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

    private var timer: Timer?
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func startRun(for route: Route) {
        print(route.name ?? "Unnamed Route")
        let routePins = route.routePins as? Set<RoutePin> ?? []
        let sortedPins = routePins.sorted { $0.order < $1.order }.compactMap { $0.pin }
        
        guard !sortedPins.isEmpty else { return }
        print(route.name ?? "Unnamed Route")
        let newLog = Log(context: viewContext)
        newLog.id = UUID()
        newLog.startTime = Date()
        newLog.route = route

        for (index, pin) in sortedPins.enumerated() {
            let loggedPin = LoggedPin(context: viewContext)
            loggedPin.id = UUID()
            loggedPin.pin = pin
            loggedPin.log = newLog
            loggedPin.order = Int32(index)
            
            if index == 0 {
                loggedPin.runningTime = 0
                loggedPin.splitTime = 0
            }
        }
        
        self.activeLog = newLog
        self.nextSplitIndex = 1
        
        accumulatedTime = 0
        startTime = Date()
        startTimer()
        runState = .running
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
        
        if nextSplitIndex == loggedPins.count - 1 {
            finishRun()
        } else {
            nextSplitIndex += 1
        }
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
        reset()
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
    
    private func currentElapsedTime() -> TimeInterval {
        return accumulatedTime + Date().timeIntervalSince(startTime ?? Date())
    }
}

