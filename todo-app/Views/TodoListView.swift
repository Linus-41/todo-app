import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var showingAddTodoView = false
    
    init(viewModel: TodoListViewModel = TodoListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView("Loading Todos...")
            }
            else if let errorMessage = viewModel.errorMessage {
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
                .overlay(content: {
                    if viewModel.todos.isEmpty{
                        Text("No todos created yet!")
                        Spacer()
                    }
                })
                .navigationBarTitle("ToDo")
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading, content: {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                        }
                    })
                    
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button(action: {
                            showingAddTodoView = true
                        }, label: {
                            Image(systemName: "plus")
                        })
                    })
                })
                .onAppear {
                    viewModel.fetchTodos()
                }
                .sheet(isPresented: $showingAddTodoView) {
                    AddTodoView(viewModel: AddTodoViewModel(),todoListViewModel: viewModel)
                }
            }
        }
    }
    
    private func deleteTodo(at offsets: IndexSet) {
        let indexes = offsets.map { $0 }
        
        for index in indexes {
            let todo = viewModel.todos[index]
            viewModel.deleteTodo(todo)
        }
    }
}

#Preview {
    TodoListView(viewModel: TodoListViewModel(todos: Todo.mockData))
}
