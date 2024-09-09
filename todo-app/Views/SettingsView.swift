import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account")) {
                    Button("Sign Out", action: {
                        
                    })
                    .foregroundStyle(.red)
                }
                
            
            }
            .navigationBarTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
