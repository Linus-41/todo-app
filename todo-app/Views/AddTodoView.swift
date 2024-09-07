import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddTodoViewModel
    var todoViewModel: TodoViewModel
    
    var body: some View {
        NavigationView {
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
                    Button("Done") {
                        addTodo()
                    }
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
        todoViewModel.addTodo(newTodo)
        dismiss()
    }
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView(viewModel: AddTodoViewModel(), todoViewModel: TodoViewModel())
    }
}
