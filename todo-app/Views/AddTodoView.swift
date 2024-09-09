import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddTodoViewModel
    var todoListViewModel: TodoListViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                    TextField("Text", text: $viewModel.text)
                    Toggle("Done", isOn: $viewModel.isDone)
                } footer: {
                    Text("Enter todo information")
                }
            }
            .navigationTitle("Add New Todo")
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: addTodo)
                    .disabled(!viewModel.isFormValid)
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
        let newTodo = viewModel.createTodo()
        todoListViewModel.addTodo(newTodo)
        dismiss()
    }
}
