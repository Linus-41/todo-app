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
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isDone.toggle()
        }
    }
}
