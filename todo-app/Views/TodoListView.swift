import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoViewModel()
    
    
    init(viewModel: TodoViewModel = TodoViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Todos...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else {
                    List(viewModel.todos) { todo in
                        HStack{
                            VStack(alignment: .leading) {
                                Text(todo.title)
                                    .font(.headline)
                                if let text = todo.text {
                                    Text(text)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
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
                                viewModel.toggleTodoCompletion(todo)
                            }
                        }
                        
                    }
                }
            }
            .navigationBarTitle("To-Do List")
            .onAppear {
                viewModel.fetchTodos()
            }
        }
    }
}

#Preview {
    TodoListView(viewModel: TodoViewModel(todos: Todo.mockData))
}
