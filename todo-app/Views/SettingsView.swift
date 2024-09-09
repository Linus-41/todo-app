import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account")) {
                    Button("Sign Out", action: {
                        contentViewModel.isSignedIn = false
                    })
                    .foregroundStyle(.red)
                }
            }
            .navigationBarTitle("Settings")
        }
        .onChange(of: contentViewModel.isSignedIn, initial: false) { oldValue, newValue in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    SettingsView()
}
