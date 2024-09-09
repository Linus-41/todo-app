import Foundation

class TodoListViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasFetchedTodos = false

    
    init(todos: [Todo] = []) {
        if !todos.isEmpty {
            self.todos = todos
        }
    }
    
    
    func fetchTodos() {
        if hasFetchedTodos {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.hasFetchedTodos = true
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
        APIService.shared.toggleTodoStatus(todoId: todo.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self?.todos.firstIndex(where: { $0.id == todo.id }) {
                        self?.todos[index].isDone.toggle()
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to update status: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func deleteTodo(_ todo: Todo) {
        APIService.shared.deleteTodo(todoId: todo.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self?.todos.firstIndex(where: { $0.id == todo.id }) {
                        self?.todos.remove(at: index)
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to delete todo: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addTodo(_ todo: TodoCreate) {
        APIService.shared.createTodo(todo: todo) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newTodo):
                    self?.todos.append(newTodo)
                case .failure(let error):
                    self?.errorMessage = "Failed to add todo: \(error.localizedDescription)"
                }
            }
        }
    }
}
