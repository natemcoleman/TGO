import SwiftUI
import CoreData

struct RouteListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Route.createdAt, ascending: false)],
        animation: .default)
    private var routes: FetchedResults<Route>

    @State private var isShowingAddSheet = false
    @State private var isShowingAddPins = false

    var body: some View {
        NavigationView {
            List {
                ForEach(routes) { route in
                    // Wrap the card in a NavigationLink to the editor
                    NavigationLink(destination: AddEditRouteView(routeToEdit: route)) {
                        RouteCardView(route: route)
                    }
                }
                .onDelete(perform: deleteRoutes)
            }
            .listStyle(InsetGroupedListStyle()) // A slightly nicer style
            .navigationTitle("Routes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isShowingAddPins = true }) {
                        Image(systemName: "mappin.and.ellipse.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                // Present the sheet for adding a NEW route (routeToEdit is nil)
                AddEditRouteView(routeToEdit: nil)
            }
            .sheet(isPresented: $isShowingAddPins) {
                // Present the sheet for adding a NEW route (routeToEdit is nil)
                PinMapView()
            }
        }
    }

    private func deleteRoutes(offsets: IndexSet) {
        withAnimation {
            offsets.map { routes[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete route: \(error.localizedDescription)")
            }
        }
    }
}

struct RouteCardView: View {
    @ObservedObject var route: Route

    var body: some View {
        // --- MODIFICATION IS HERE ---
        // Calculate the sorted pins as a local constant inside the view's body.
        let sortedPins = (route.routePins as? Set<RoutePin> ?? [])
            .sorted { $0.order < $1.order }
            .compactMap { $0.pin }
        // ---------------------------
        
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(route.name ?? "Untitled Route")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(route.desc ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // Use the 'sortedPins' constant we just created.
            if !sortedPins.isEmpty {
                Divider()
                Text("Checkpoints: \(sortedPins.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    RouteListView().environment(
        \.managedObjectContext,
        PersistenceController.preview.container.viewContext
    )
}

