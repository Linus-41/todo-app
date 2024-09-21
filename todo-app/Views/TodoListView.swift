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
                    ForEach(todoListViewModel.getFilteredTodos(category: nil, isDone: false)){todo in
                        TodoItemView(todo: todo, toggleStatus: {todoListViewModel.toggleTodoCompletion(todo)})
                    }
                    
                    ForEach(todoListViewModel.categories){category in
                        Section(category.name, content: {
                            ForEach(todoListViewModel.getFilteredTodos(category: category, isDone: false)){todo in
                                TodoItemView(todo: todo, toggleStatus: {todoListViewModel.toggleTodoCompletion(todo)})
                            }
                        })
                    }
                    Section{
                        DisclosureGroup("Done"){
                            ForEach(todoListViewModel.todos){todo in
                                if todo.isDone == true{
                                    TodoItemView(todo: todo, toggleStatus: {todoListViewModel.toggleTodoCompletion(todo)})
                                }
                            }
                        }
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
                    todoListViewModel.fetchCategories()
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
}

#Preview {
    TodoListView()
        .onAppear{
            
            //KeychainService.shared.clearTokens()
            KeychainService.shared.deleteTokenExpiration()
            KeychainService.shared.saveRefreshToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0dXNlcjEyMyIsImV4cCI6MTcyOTQyMTY1MH0.HchtFpVKuVX9TNjGwOb-RWggSx6EaW4C8o4BPrO1O1Q")
            
        }
}
