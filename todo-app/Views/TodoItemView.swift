import SwiftUI

struct TodoItemView: View {
    
    var todo: Todo
    var toggleStatus: () -> Void
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(todo.title)
                    .font(.headline)
                if let text = todo.text{
                    Text(text)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName:
                    todo.isDone
                  ? "checkmark.circle.fill"
                  : "circle")
            .foregroundColor(todo.isDone
                             ? .green
                             : .gray)
            .onTapGesture {
                toggleStatus()
            }
        }
    }
}


#Preview {
    TodoItemView(todo: Todo(id: 1, title: "Test-ToDo", text: "This has to be done", isDone: true, categoryId: nil, ownerId: 1, position: 1), toggleStatus: {
    })
}
