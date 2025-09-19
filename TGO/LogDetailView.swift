import SwiftUI
import CoreData
import MapKit

let strokeStyle = StrokeStyle(
    lineWidth: 5,
    lineCap: .round,
    lineJoin: .round,
)

struct LogDetailView: View {
    let log: Log
    @State private var isShowingEditSheet = false
    @State private var decodedRoute: [CLLocationCoordinate2D] = []
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        let sortedLoggedPins = (log.loggedPins as? Set<LoggedPin> ?? [])
            .sorted { $0.order < $1.order }
        
        VStack{
            Map(position: $mapPosition) {
                if !decodedRoute.isEmpty {
                    MapPolyline(coordinates: decodedRoute)
                        .stroke(.blue, style: strokeStyle)
                }
                //
                //                ForEach(sortedLoggedPins) { pin in
                //                    Annotation(pin.name ?? "Pin", coordinate: pin.coordinate) {
                //                        Image(systemName: "flag.fill")
                //                            .foregroundColor(.black)
                //                            .padding()
                //                            .shadow(radius: 2)
                //                    }
                //                }
            }
            .mapStyle(.standard)
            .cornerRadius(50)
            .frame(width: 400, height: 300)
            
            Spacer()
            
            List {
                Section("Summary") {
                    HStack {
                        Text("Route")
                        Spacer()
                        Text(log.route?.name ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(log.startTime ?? Date(), style: .date)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Total Time")
                        Spacer()
                        Text(formatTime(log.totalTime))
                            .font(.body.monospaced())
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Checkpoints") {
                    ForEach(sortedLoggedPins) { loggedPin in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(loggedPin.displayName ?? loggedPin.pin?.name ?? "Unknown Pin")
                                    .font(.headline)
                                
                                Text("Split: \(formatTime(loggedPin.splitTime))")
                                    .font(.caption.monospaced())
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(formatTime(loggedPin.runningTime))
                                .font(.body.monospaced())
                        }
                    }
                }
//                Section("Polyline") {
//                    HStack {
//                        Text("Polyline:")
//                            .font(.caption.monospaced())
//                            .foregroundColor(.secondary)
//                        Spacer()
//                        Text(log.polyline ?? "")
//                            .textSelection(.enabled)
//                    }
//                }
            }
            .navigationTitle("Run Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isShowingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditLogView(log: log)
            }
        }
        .onAppear(perform: showSavedRoute)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private func showSavedRoute() {
        guard let polyline = log.polyline, !polyline.isEmpty else {
            print("No saved route to show.")
            return
        }
        decodedRoute = Polyline.decode(polyline: polyline)
        let test = Polyline.decode(polyline: polyline)
        decodedRoute = test
        
        if let routeRect = decodedRoute.boundingMapRect {
            mapPosition = .rect(routeRect.paddedBy(factor: 0.1))
        }
    }
}

extension Array where Element == CLLocationCoordinate2D {
    var boundingMapRect: MKMapRect? {
        guard let firstPoint = self.first else { return nil }
        
        var rect = MKMapRect(origin: MKMapPoint(firstPoint), size: MKMapSize(width: 0, height: 0))
        
        for coordinate in self {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        return rect
    }
}

extension MKMapRect {
    func paddedBy(factor: CGFloat) -> MKMapRect {
        return self.insetBy(dx: -self.width * factor, dy: -self.height * factor)
    }
}

//#Preview{
//    LogDetailView()
//}
