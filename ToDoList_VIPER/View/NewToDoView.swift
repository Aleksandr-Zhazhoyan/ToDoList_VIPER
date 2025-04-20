//
//  NewToDoView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI


struct NewToDoView: View {
    @Binding var isPresented: Bool
    @ObservedObject var presenter: ToDoPresenter
    @Binding var taskToEdit: ToDoEntity?

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var isStartTimeSet: Bool = false
    @State private var isEndTimeSet: Bool = false

    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали задачи")) {
                    TextField("Название", text: $title)
                    TextField("Детали", text: $details)
                }
                Section(header: Text("Время задачи")) {
                    DatePicker("Время начала", selection: $startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: startTime) {
                            isStartTimeSet = true
                        }

                    DatePicker("Время окончания", selection: $endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: endTime) {
                            isEndTimeSet = true
                        }
                }
                Section {
                    Button(taskToEdit == nil ? "Добавить задачу" : "Сохранить изменения") {
                        if let task = taskToEdit {
                            presenter.updateTask(task: ToDoEntity(
                                id: task.id,
                                title: title,
                                details: details,
                                createdAt: task.createdAt,
                                startTime: isStartTimeSet ? startTime : nil,
                                endTime: isEndTimeSet ? endTime : nil,
                                isCompleted: task.isCompleted)
                            ) { success in
                                if success {
                                    isPresented = false
                                } else {
                                    errorMessage = "Другая задача с таким же названием уже существует."
                                    showErrorAlert = true
                                }
                            }
                        } else {
                            presenter.addTask(
                                title: title,
                                details: details,
                                startTime: isStartTimeSet ? startTime : nil,
                                endTime: isEndTimeSet ? endTime : nil
                            ) { success in
                                if success {
                                    isPresented = false
                                } else {
                                    errorMessage = "Задача с таким же названием уже существует."
                                    showErrorAlert = true
                                }
                            }
                        }
                    }
                    .disabled(title.count < 3)
                    .foregroundStyle(.purple)
                }
            }
            .navigationTitle(taskToEdit == nil ? "Новая задача" : "Редактировать задачу")
            .navigationBarItems(leading: Button("Отмена") {
                isPresented = false
            })
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    details = task.details
                    if let taskStartTime = task.startTime {
                        startTime = taskStartTime
                        isStartTimeSet = true
                    }
                    if let taskEndTime = task.endTime {
                        endTime = taskEndTime
                        isEndTimeSet = true
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Ошибка"), message: Text(errorMessage ?? "Произошла ошибка"), dismissButton: .default(Text("OK")))
            }
        }
        .foregroundStyle(.black)
    }
}



