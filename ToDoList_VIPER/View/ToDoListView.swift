//
//  ToDoListView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI

struct ToDoListView: View {
    @ObservedObject var presenter: ToDoPresenter
    @Binding var selectedFilter: ToDoFilter
    @Binding var showNewTaskForm: Bool
    @Binding var editingTask: ToDoEntity?

    @State private var showAlert = false
    @State private var taskToDelete: ToDoEntity?

    var body: some View {
        List {
            ForEach(filteredTasks(), id: \.id) { task in
                ToDoCardView(task: task, presenter: presenter)
                    .listRowBackground(ToDoListViewConstants.listRowBackgroundColor)
                    .listRowSeparator(.hidden)
                    .contextMenu {
                        TaskContextMenu(
                            task: task,
                            onEdit: {
                                editingTask = task
                                showNewTaskForm.toggle()
                            },
                            onDelete: {
                                taskToDelete = task
                                showAlert.toggle()
                            }
                        )
                    }
            }
        }
        .listStyle(PlainListStyle())
        .background(ToDoListViewConstants.listBackgroundColor)
        .alert(isPresented: $showAlert) {
            deleteAlert
        }
    }

    private func filteredTasks() -> [ToDoEntity] {
        return presenter.filteredTasks(for: selectedFilter)
    }

    private var deleteAlert: Alert {
        Alert(
            title: Text("Удалить задачу"),
            message: Text("Вы уверены, что хотите удалить это задание?"),
            primaryButton: .destructive(Text("Да")) {
                if let taskToDelete = taskToDelete {
                    presenter.deleteTask(task: taskToDelete)
                }
            },
            secondaryButton: .cancel()
        )
    }
}

private struct TaskContextMenu: View {
    var task: ToDoEntity
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        Group {
            Button(action: onEdit) {
                Text("Редактировать")
                Image(systemName: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

// Константы для параметров верстки TaskListView
private enum ToDoListViewConstants {
    static let listRowBackgroundColor = Color.clear
    static let listBackgroundColor = Color(UIColor.systemGroupedBackground)
}
