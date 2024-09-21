import Foundation

struct Todo: Identifiable, Codable {
    let id: Int
    let title: String
    let text: String?
    var isDone: Bool
    let ownerId: Int
    let position: Int
    var category: Category?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
        case isDone = "is_done"
        case ownerId = "owner_id"
        case position
        case category
    }
}

struct TodoCreate: Codable {
    let title: String
    let text: String?
    var isDone: Bool?
    let categoryId: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case text
        case isDone = "is_done"
        case categoryId = "category_id"
    }
}

struct Category: Identifiable, Codable, Hashable {
    var id: Int
    var name: String
    var userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
    }
}

struct CategoryCreate: Codable{
    var name: String
}

extension Todo {
    static let mockData: [Todo] = [
        Todo(id: 1, title: "Buy groceries", text: "Milk, Bread, Eggs", isDone: false, ownerId: 1, position: 1),
        Todo(id: 2, title: "Meeting with Bob", text: "Discuss project details", isDone: false, ownerId: 1, position: 2),
        Todo(id: 3, title: "Read a book", text: "Finish reading '1984' by George Orwell", isDone: true, ownerId: 1, position: 3),
        Todo(id: 4, title: "Workout", text: "30 minutes of cardio", isDone: false, ownerId: 1, position: 4),
        Todo(id: 5, title: "Cook dinner", text: "Prepare pasta for dinner", isDone: false, ownerId: 1, position: 5)
    ]
}
