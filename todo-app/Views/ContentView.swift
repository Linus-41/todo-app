import SwiftUI

struct ContentView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    var body: some View {
        NavigationStack {
            if contentViewModel.isSignedIn{
                TodoListView()
            } else {
                LoginView()
            }
        }
    }
}
