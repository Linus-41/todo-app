import Foundation

struct Todo: Identifiable, Codable {
    let id: Int
    let title: String
    let text: String?
    var isDone: Bool
    let categoryId: Int?       // Optional because `category_id` can be null
    let ownerId: Int
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
        case isDone = "is_done"
        case categoryId = "category_id"
        case ownerId = "owner_id"
        case position
    }
}

struct TodoCreate: Codable {
    let title: String
    let text: String?
    var isDone: Bool?
    let categoryId: Int?       // Optional because `category_id` can be null
    
    enum CodingKeys: String, CodingKey {
        case title
        case text
        case isDone = "is_done"
        case categoryId = "category_id"
    }
}

extension Todo {
    static let mockData: [Todo] = [
        Todo(id: 1, title: "Buy groceries", text: "Milk, Bread, Eggs", isDone: false, categoryId: nil, ownerId: 1, position: 1),
        Todo(id: 2, title: "Meeting with Bob", text: "Discuss project details", isDone: false, categoryId: nil, ownerId: 1, position: 2),
        Todo(id: 3, title: "Read a book", text: "Finish reading '1984' by George Orwell", isDone: true, categoryId: nil, ownerId: 1, position: 3),
        Todo(id: 4, title: "Workout", text: "30 minutes of cardio", isDone: false, categoryId: nil, ownerId: 1, position: 4),
        Todo(id: 5, title: "Cook dinner", text: "Prepare pasta for dinner", isDone: false, categoryId: nil, ownerId: 1, position: 5)
    ]
}
