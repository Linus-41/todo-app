import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var addCategoryViewModel = AddCategoryViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $addCategoryViewModel.name)
                } footer: {
                    Text("Enter category information")
                }
            }
            .navigationTitle("Add new category")
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: {
                    })
                        
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            })
        }
    }
}

#Preview {
    AddCategoryView()
}
