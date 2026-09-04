import SwiftUI

@main
struct FCoreNFCApp: App {
    @StateObject private var store = CardStore()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(store: store))
        }
    }
}

