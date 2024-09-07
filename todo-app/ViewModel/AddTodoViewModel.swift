import Foundation

class AddTodoViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var text: String = ""
    @Published var isDone: Bool = false
    
    var isFormValid: Bool {
        return !title.isEmpty
    }
    
    func createTodo() -> TodoCreate {
        return TodoCreate(title: title, text: text, isDone: isDone, categoryId: nil)
    }
}
