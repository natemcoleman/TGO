////
////  HomeView 2.swift
////  TGO
////
////  Created by Brooklyn Daines on 9/13/25.
////
//
//
//import SwiftUI
//import MapKit
//import CoreData
//import CoreLocation
//
//struct HomeView2: View {
//    // MARK: - State and View Models
//    @StateObject private var timerViewModel = TimerViewModel()
//    @StateObject var locationManager = LocationManager()
//    
//    @State private var position: MapCameraPosition = .automatic
//    @State private var selectedRoute: Route?
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Pin.order, ascending: true)],
//        animation: .default)
//    private var allPins: FetchedResults<Pin>
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Route.createdAt, ascending: true)],
//        animation: .default)
//    private var routes: FetchedResults<Route>
//    
//    private var pinsToShow: [Pin] {
//        guard let route = selectedRoute else {
//            return Array(allPins)
//        }
//        let routePins = route.routePins as? Set<RoutePin> ?? []
//        return routePins.sorted { $0.order < $1.order }.compactMap { $0.pin }
//    }
//    
//    // MARK: - Body
//    var body: some View {
//        VStack {
//            Map(position: $position) {
//                ForEach(pinsToShow) { pin in
//                    Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
//                        Image(systemName: "flag.circle.fill")
//                            .foregroundColor(.green)
//                            .padding()
//                            .shadow(radius: 2)
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//            .frame(width: 300, height: 300)
//            .cornerRadius(50)
//            .shadow(radius: 10)
//            
//            Picker("Select a Route", selection: $selectedRoute) {
//                Text("Show All Pins").tag(nil as Route?)
//                
//                ForEach(routes) { route in
//                    Text(route.name ?? "Unnamed Route").tag(route as Route?)
//                }
//            }
//            .pickerStyle(.menu)
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .shadow(radius: 2)
//            
//            // Timer and Splits Display
//            if timerViewModel.runState != .notStarted {
//                VStack {
//                    Text(formatTime(timerViewModel.elapsedTime))
//                        .font(.system(size: 48, weight: .bold, design: .monospaced))
//                    
//                    // Display the list of splits
//                    ForEach(Array(timerViewModel.splits.enumerated()), id: \.offset) { index, splitTime in
//                        HStack {
//                            Text("Split \(index + 1)")
//                            Spacer()
//                            Text(formatTime(splitTime))
//                        }
//                        .font(.system(.body, design: .monospaced))
//                    }
//                }
//                .padding()
//            }
//            
//            VStack(alignment: .leading) {
//                HStack {
//                    Text("Name").bold().frame(width: 120, alignment: .leading)
//                    Text("Order").bold()
//                }
//                ForEach(Array(pinsToShow.enumerated()), id: \.element.id) { index, pin in
//                    HStack {
//                        Text(pin.name ?? "Unnamed")
//                            .frame(width: 120, alignment: .leading)
//                        Text("\(index + 1)")
//                    }
//                }
//            }
//            .padding()
//            
//            Spacer()
//            
//            // Dynamic Timer Controls
//            timerControls
//            
//            Spacer()
//        }
//    }
//    
//    // MARK: - Timer Controls View
//    @ViewBuilder
//    private var timerControls: some View {
//        switch timerViewModel.runState {
//        case .notStarted:
//            Button(action: { timerViewModel.start() }) {
//                Image(systemName: "arrowtriangle.right.circle.fill")
//                    .resizable().scaledToFit().frame(width: 100, height: 100)
//            }
//            .foregroundColor(.green)
//
//        case .running:
//            HStack(spacing: 20) {
//                Button(action: { timerViewModel.pause() }) { Text("Pause") }
//                    .buttonStyle(.borderedProminent).tint(.orange)
//                
//                Button(action: { timerViewModel.finish() }) { Text("Finish") }
//                    .buttonStyle(.borderedProminent).tint(.red)
//                
//                Button(action: { timerViewModel.split() }) { Text("Split") }
//                    .buttonStyle(.bordered).tint(.blue)
//            }
//
//        case .paused:
//            HStack(spacing: 20) {
//                Button(action: { timerViewModel.resume() }) { Text("Resume") }
//                    .buttonStyle(.borderedProminent).tint(.green)
//                
//                Button(action: { timerViewModel.finish() }) { Text("Finish") }
//                    .buttonStyle(.borderedProminent).tint(.red)
//            }
//        }
//    }
//    
//    // MARK: - Helper Functions
//    private func formatTime(_ interval: TimeInterval) -> String {
//        let minutes = Int(interval) / 60
//        let seconds = Int(interval) % 60
//        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
//        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
//    }
//}
//
//#Preview {
//    HomeView2()
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
