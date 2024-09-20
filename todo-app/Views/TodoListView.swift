import SwiftUI

struct TodoListView: View {
    @StateObject private var todoListViewModel = TodoListViewModel()
    @State private var showingAddTodoView = false
    
    
    var body: some View {
        NavigationStack {
            if todoListViewModel.isLoading {
                ProgressView("Loading Todos...")
            }
            else if let errorMessage = todoListViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                List {
                    ForEach(todoListViewModel.todos){ todo in
                        if todo.category == nil{
                            TodoItemView(todo: todo, toggleStatus: {
                                todoListViewModel.toggleTodoCompletion(todo)
                            })
                        }
                    }
                    .onDelete(perform: deleteTodo)
                    
                    ForEach(getCategories(todos: todoListViewModel.todos)){ category in
                        Section(category.name, content: {
                            ForEach(todoListViewModel.todos) { todo in
                                if todo.category == category{
                                    TodoItemView(todo: todo, toggleStatus: {
                                        todoListViewModel.toggleTodoCompletion(todo)
                                    })
                                }
                            }
                            .onDelete(perform: deleteTodo)
                        })
                    }
                    
                    Button(action: {
                        
                    }, label: {
                        Label("Add new Category", systemImage: "plus")
                    })
                        
                    
                }
                .overlay(content: {
                    if todoListViewModel.todos.isEmpty{
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
                    todoListViewModel.fetchTodos()
                    print(getCategories(todos: todoListViewModel.todos))
                }
                .sheet(isPresented: $showingAddTodoView) {
                    AddTodoView(todoListViewModel: todoListViewModel)
                }
            }
        }
    }
    
    private func deleteTodo(at offsets: IndexSet) {
        let indexes = offsets.map { $0 }
        
        for index in indexes {
            let todo = todoListViewModel.todos[index]
            todoListViewModel.deleteTodo(todo)
        }
    }
    
    private func getCategories(todos: [Todo]) -> [Category] {
        var categoriesSet = Set<Category>()
        
        for todo in todos {
            if let category = todo.category {
                categoriesSet.insert(category)
            }
        }
        
        return Array(categoriesSet)
    }
}

#Preview {
    TodoListView()
        .onAppear{
            
            //KeychainService.shared.clearTokens()
            KeychainService.shared.deleteTokenExpiration()
            KeychainService.shared.saveRefreshToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0dXNlcjEyMyIsImV4cCI6MTcyOTQyMTY1MH0.HchtFpVKuVX9TNjGwOb-RWggSx6EaW4C8o4BPrO1O1Q")
            
        }
}
