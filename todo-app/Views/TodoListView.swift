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
                    List {
                        ForEach(viewModel.todos) { todo in
                            HStack {
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
                        .onDelete(perform: deleteTodo)
                    }
                }
            }
            .navigationBarTitle("To-Do List")
            .onAppear {
                viewModel.fetchTodos()
            }
        }
    }
    
    // Function to handle the deletion of a todo
    private func deleteTodo(at offsets: IndexSet) {
        // Convert IndexSet to Array of indexes
        let indexes = offsets.map { $0 }
        
        // Handle deletion for each index
        for index in indexes {
            let todo = viewModel.todos[index]
            viewModel.deleteTodo(todo)
        }
    }
}

#Preview {
    TodoListView(viewModel: TodoViewModel(todos: Todo.mockData))
}
