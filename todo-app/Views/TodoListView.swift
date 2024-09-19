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
                    ForEach(todoListViewModel.todos) { todo in
                        TodoItemView(todo: todo, toggleStatus: {
                            todoListViewModel.toggleTodoCompletion(todo)
                        })
                    }
                    .onDelete(perform: deleteTodo)
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
            KeychainService.shared.saveRefreshToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJsaW51cyIsImV4cCI6MTcyOTM1OTU3OX0.ZawDqRDDUvarwr1QlmgvsaDo3JO35Jf-GB6V_AHROlA")
        }
}
