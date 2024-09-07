import SwiftUI

struct AddTodoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var isDone: Bool = false
    @ObservedObject var viewModel: TodoViewModel
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Text", text: $text)
                Toggle("Done", isOn: $isDone)
                
                Button(action: addTodo) {
                    Text("Add Todo")
                }
                .disabled(title.isEmpty) // Disable button if title is empty
            }
            .navigationBarTitle("Add New Todo")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addTodo() {
        let newTodo = TodoCreate(title: title, text: text, isDone: isDone, categoryId: nil)
        viewModel.addTodo(newTodo)
        presentationMode.wrappedValue.dismiss()
    }
}
