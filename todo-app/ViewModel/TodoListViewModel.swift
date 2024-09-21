import Foundation

class TodoListViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasFetchedTodos = false
    @Published var hasFetchedCategories = false
    
    
    init(todos: [Todo] = []) {
        if !todos.isEmpty {
            self.todos = todos
        }
    }
    
    func getFilteredTodos(category: Category? = nil, isDone: Bool = false) -> [Todo]{
        var filteredTodos: [Todo] = []
        for todo in todos {
            if todo.category == category && todo.isDone == isDone{
                filteredTodos.append(todo)
            }
        }
        return filteredTodos
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
    
    
    
    func fetchCategories(){
        if hasFetchedCategories{
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.hasFetchedCategories = true
                switch result {
                case .success(let categories):
                    self?.categories = categories
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
            
        }
    }
    
    func addCategory(_ category: CategoryCreate) {
        APIService.shared.createCategory(category: category) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newCategory):
                    self?.categories.append(newCategory)
                case .failure(let error):
                    self?.errorMessage = "Failed to add category: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteCategory(_ category: Category) {
        APIService.shared.deleteCategory(categoryId: category.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self?.categories.firstIndex(where: { $0.id == category.id }) {
                        self?.categories.remove(at: index)
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to delete category: \(error.localizedDescription)"
                }
            }
        }
    }
    
}
