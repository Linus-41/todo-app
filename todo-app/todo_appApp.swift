import SwiftUI

@main
struct todo_appApp: App {
    @StateObject var contentViewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentViewModel)
        }
    }
}



#Preview{
    ContentView()
}
