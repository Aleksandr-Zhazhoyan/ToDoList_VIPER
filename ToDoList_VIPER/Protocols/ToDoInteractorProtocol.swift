//
//  ToDoInteractorProtocol.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation

protocol ToDoInteractorProtocol {
    func fetchTasks(completion: @escaping ([ToDoEntity]) -> Void)
    func fetchTasksFromAPI(completion: @escaping ([ToDoEntity]) -> Void)
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void)
    func updateTask(task: ToDoEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void)
    func deleteTask(task: ToDoEntity, completion: @escaping () -> Void)
}
