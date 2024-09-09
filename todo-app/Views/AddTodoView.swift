import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var addTodoViewModel = AddTodoViewModel()
    var todoListViewModel: TodoListViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $addTodoViewModel.title)
                    TextField("Text", text: $addTodoViewModel.text)
                    Toggle("Done", isOn: $addTodoViewModel.isDone)
                } footer: {
                    Text("Enter todo information")
                }
            }
            .navigationTitle("Add New Todo")
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: addTodo)
                        .disabled(!addTodoViewModel.isFormValid)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            })
        }
    }
    
    private func addTodo() {
        let newTodo = addTodoViewModel.createTodo()
        todoListViewModel.addTodo(newTodo)
        dismiss()
    }
}
