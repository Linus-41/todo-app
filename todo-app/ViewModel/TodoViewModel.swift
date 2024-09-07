import Foundation

class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(todos: [Todo] = []) {
        if !todos.isEmpty {
            self.todos = todos
        }
    }
    
    
    func fetchTodos() {
        if !todos.isEmpty{
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let todos):
                    self?.todos = todos
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func toggleTodoCompletion(_ todo: Todo) {
            // Start by sending the request to the API
            APIService.shared.toggleTodoStatus(todoId: todo.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // Update the local state if the server request was successful
                        if let index = self?.todos.firstIndex(where: { $0.id == todo.id }) {
                            self?.todos[index].isDone.toggle()
                        }
                    case .failure(let error):
                        // Handle error (e.g., show an alert or message to the user)
                        self?.errorMessage = "Failed to update status: \(error.localizedDescription)"
                    }
                }
            }
        }
}
