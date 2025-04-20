//
//  ToDoPresenterProtocol.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation


protocol ToDoPresenterProtocol: ObservableObject {
    func loadTasks()
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, completion: @escaping (Bool) -> Void)
    func toggleTaskCompletion(task: ToDoEntity)
    func updateTask(task: ToDoEntity, completion: @escaping (Bool) -> Void)
    func deleteTask(task: ToDoEntity)
}
