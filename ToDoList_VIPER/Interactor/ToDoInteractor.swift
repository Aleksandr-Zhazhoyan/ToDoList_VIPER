//
//  ToDoInteractor.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

//import Foundation
//import CoreData
//
//
///// ToDoInteractor отвечает за управление задачами (ToDoEntity) в приложении.
///// Он предоставляет функциональность для создания, обновления, удаления и загрузки задач как из локальной базы данных (Core Data),
///// так и из удаленного API. Все операции выполняются асинхронно с использованием GCD, что обеспечивает
///// неконкурентное выполнение задач в фоновом режиме и предотвращает блокировку основного потока.
///// Это позволяет приложению оставаться отзывчивым, даже при выполнении длительных операций с данными.
//final class ToDoInteractor: ToDoInteractorProtocol {
//    
//    // Используем общие константы для строковых значений
//    private enum Constants {
//        static let taskQueueLabel = "com.todoApp.taskQueue"
//        static let titlePredicateFormat = "title == %@"
//        static let idPredicateFormat = "id == %@"
//        static let apiUrl = "https://dummyjson.com/todos"
//    }
//    
//    private let context = PersistenceController.shared.viewContext
//    private let queue = DispatchQueue(label: Constants.taskQueueLabel, attributes: .concurrent)
//    
//    // Fetch tasks from Core Data
//    func fetchTasks(completion: @escaping ([ToDoEntity]) -> Void) {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//            
//            let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
//
//            
//            do {
//                let tasks = try self.context.fetch(fetchRequest)
//                let taskEntities = tasks.compactMap { task -> ToDoEntity? in
//                    guard let id = task.id,
//                          let title = task.title,
//                          let details = task.details,
//                          let createdAt = task.createdAt else {
//                        return nil
//                    }
//                    return ToDoEntity(
//                        id: id,
//                        title: title,
//                        details: details,
//                        createdAt: createdAt,
//                        startTime: task.startTime,
//                        endTime: task.endTime,
//                        isCompleted: task.isCompleted
//                    )
//                }
//                DispatchQueue.main.async {
//                    completion(taskEntities)
//                }
//            } catch {
//                print("Failed to fetch tasks: \(error)")
//                DispatchQueue.main.async {
//                    completion([])
//                }
//            }
//        }
//    }
//
//
//    // Fetch tasks from API
//    func fetchTasksFromAPI(completion: @escaping ([ToDoEntity]) -> Void) {
//        guard let url = URL(string: Constants.apiUrl) else {
//            DispatchQueue.main.async {
//                completion([])
//            }
//            return
//        }
//        
//        queue.async { [weak self] in
//            guard let self = self else { return }
//            URLSession.shared.dataTask(with: url) { data, response, error in
//                if let error = error {
//                    print("Failed to fetch tasks: \(error)")
//                    DispatchQueue.main.async {
//                        completion([])
//                    }
//                    return
//                }
//                
//                guard let data = data else {
//                    print("No data received")
//                    DispatchQueue.main.async {
//                        completion([])
//                    }
//                    return
//                }
//                
//                do {
//                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
//                    let tasks = decodedResponse.todos.map { apiTask -> ToDoEntity in
//                        ToDoEntity(
//                            id: UUID(),
//                            title: apiTask.todo,
//                            details: "",
//                            createdAt: Date(),
//                            startTime: nil,
//                            endTime: nil,
//                            isCompleted: apiTask.completed
//                        )
//                    }
//                    
//                    self.saveTasksToCoreData(tasks: tasks)
//                    
//                    DispatchQueue.main.async {
//                        completion(tasks)
//                    }
//                } catch {
//                    print("Failed to decode tasks: \(error)")
//                    DispatchQueue.main.async {
//                        completion([])
//                    }
//                }
//            }.resume()
//        }
//    }
//
//    // Save tasks to Core Data
//    private func saveTasksToCoreData(tasks: [ToDoEntity]) {
//        queue.async(flags: .barrier) { [weak self] in
//            guard let self = self else { return }
//            tasks.forEach { taskEntity in
//                let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
//                
//                fetchRequest.predicate = NSPredicate(format: Constants.titlePredicateFormat, taskEntity.title)
//                
//                do {
//                    let existingTasks = try self.context.fetch(fetchRequest)
//                    if existingTasks.isEmpty {
//                        let newTask = ToDoTask(context: self.context)
//                        newTask.id = taskEntity.id
//                        newTask.title = taskEntity.title
//                        newTask.details = taskEntity.details
//                        newTask.createdAt = taskEntity.createdAt
//                        newTask.startTime = taskEntity.startTime
//                        newTask.endTime = taskEntity.endTime
//                        newTask.isCompleted = taskEntity.isCompleted
//                    }
//                } catch {
//                    print("Failed to check for existing task: \(error)")
//                }
//            }
//            self.saveContext()
//        }
//    }
//
//    // Add a new task
//    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
//        queue.async(flags: .barrier) { [weak self] in
//            guard let self = self else { return }
//            let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
//            
//            fetchRequest.predicate = NSPredicate(format: Constants.titlePredicateFormat, title)
//            
//            do {
//                let existingTasks = try self.context.fetch(fetchRequest)
//                if existingTasks.isEmpty {
//                    let newTask = ToDoTask(context: self.context)
//                    newTask.id = UUID()
//                    newTask.title = title
//                    newTask.details = details
//                    newTask.createdAt = Date()
//                    newTask.startTime = startTime
//                    newTask.endTime = endTime
//                    newTask.isCompleted = false
//
//                    self.saveContext()
//                    
//                    DispatchQueue.main.async {
//                        onSuccess()
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        onFailure(nil)
//                    }
//                }
//            } catch {
//                print("Failed to add task: \(error)")
//                DispatchQueue.main.async {
//                    onFailure(error)
//                }
//            }
//        }
//    }
//
//    // Update an existing task
//    func updateTask(task: ToDoEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
//        queue.async(flags: .barrier) { [weak self] in
//            guard let self = self else { return }
//            let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
//            
//            fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, task.id as CVarArg)
//            
//            do {
//                let tasks = try self.context.fetch(fetchRequest)
//                if let taskToUpdate = tasks.first {
//                    let titleCheckRequest = ToDoTask.fetchRequest() as! NSFetchRequest
//                    titleCheckRequest.predicate = NSPredicate(format: "\(Constants.titlePredicateFormat) AND id != %@", task.title, task.id as CVarArg)
//                    
//                    let existingTasksWithTitle = try self.context.fetch(titleCheckRequest)
//                    
//                    if existingTasksWithTitle.isEmpty {
//                        taskToUpdate.title = task.title
//                        taskToUpdate.details = task.details
//                        taskToUpdate.startTime = task.startTime
//                        taskToUpdate.endTime = task.endTime
//                        taskToUpdate.isCompleted = task.isCompleted
//                        self.saveContext()
//                        
//                        DispatchQueue.main.async {
//                            onSuccess()
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            onFailure(nil)
//                        }
//                    }
//                } else {
//                    print("Task not found")
//                    DispatchQueue.main.async {
//                        onFailure(nil)
//                    }
//                }
//            } catch {
//                print("Failed to update task: \(error)")
//                DispatchQueue.main.async {
//                    onFailure(error)
//                }
//            }
//        }
//    }
//
//    // Delete a task
//    func deleteTask(task: ToDoEntity, completion: @escaping () -> Void) {
//        queue.async(flags: .barrier) { [weak self] in
//            guard let self = self else { return }
//            let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
//            
//            fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, task.id as CVarArg)
//            
//            do {
//                let tasks = try self.context.fetch(fetchRequest)
//                if let taskToDelete = tasks.first {
//                    self.context.delete(taskToDelete as! NSManagedObject)
//                    self.saveContext()
//                } else {
//                    print("Task not found")
//                }
//            } catch {
//                print("Failed to delete task: \(error)")
//            }
//
//            DispatchQueue.main.async {
//                completion()
//            }
//        }
//    }
//
//    // Save the Core Data context
//    private func saveContext() {
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save context: \(error)")
//        }
//    }
//}
//

import Foundation
import CoreData

final class ToDoInteractor: ToDoInteractorProtocol {

    private enum Constants {
        static let taskQueueLabel = "com.todoApp.taskQueue"
        static let titlePredicateFormat = "title == %@"
        static let idPredicateFormat = "id == %@"
        static let apiUrl = "https://dummyjson.com/todos"
    }

    private let context = PersistenceController.shared.viewContext
    private let queue = DispatchQueue(label: Constants.taskQueueLabel, attributes: .concurrent)

    // MARK: - Fetch from Core Data
    func fetchTasks(completion: @escaping ([ToDoEntity]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }

            let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()

            do {
                let tasks = try self.context.fetch(fetchRequest)
                let taskEntities = tasks.compactMap { task -> ToDoEntity? in
                    guard let id = task.id,
                          let title = task.title,
                          let details = task.details,
                          let createdAt = task.createdAt else {
                        return nil
                    }

                    return ToDoEntity(
                        id: id,
                        title: title,
                        details: details,
                        createdAt: createdAt,
                        startTime: task.startTime,
                        endTime: task.endTime,
                        isCompleted: task.isCompleted
                    )
                }

                DispatchQueue.main.async {
                    completion(taskEntities)
                }

            } catch {
                print("Failed to fetch tasks: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    // MARK: - Fetch from API
    func fetchTasksFromAPI(completion: @escaping ([ToDoEntity]) -> Void) {
        guard let url = URL(string: Constants.apiUrl) else {
            DispatchQueue.main.async { completion([]) }
            return
        }

        queue.async { [weak self] in
            guard let self = self else { return }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to fetch tasks: \(error)")
                    DispatchQueue.main.async { completion([]) }
                    return
                }

                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async { completion([]) }
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    let tasks = decodedResponse.todos.map {
                        ToDoEntity(
                            id: UUID(),
                            title: $0.todo,
                            details: "",
                            createdAt: Date(),
                            startTime: nil,
                            endTime: nil,
                            isCompleted: $0.completed
                        )
                    }

                    self.saveTasksToCoreData(tasks: tasks)

                    DispatchQueue.main.async {
                        completion(tasks)
                    }

                } catch {
                    print("Failed to decode tasks: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    }

    // MARK: - Save to Core Data
    private func saveTasksToCoreData(tasks: [ToDoEntity]) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            tasks.forEach { taskEntity in
                let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
                fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, taskEntity.id as CVarArg)

                do {
                    let existingTasks = try self.context.fetch(fetchRequest)
                    if let existingTask = existingTasks.first {
                        existingTask.title = taskEntity.title
                        existingTask.details = taskEntity.details
                        existingTask.startTime = taskEntity.startTime
                        existingTask.endTime = taskEntity.endTime
                        existingTask.isCompleted = taskEntity.isCompleted
                    } else {
                        let newTask = ToDoTask(context: self.context)
                        newTask.id = taskEntity.id
                        newTask.title = taskEntity.title
                        newTask.details = taskEntity.details
                        newTask.createdAt = taskEntity.createdAt
                        newTask.startTime = taskEntity.startTime
                        newTask.endTime = taskEntity.endTime
                        newTask.isCompleted = taskEntity.isCompleted
                    }
                } catch {
                    print("Failed to fetch or update task: \(error)")
                }
            }

            self.saveContext()
        }
    }


    // MARK: - Add Task
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            let newTask = ToDoTask(context: self.context)
            newTask.id = UUID()
            newTask.title = title
            newTask.details = details
            newTask.createdAt = Date()
            newTask.startTime = startTime
            newTask.endTime = endTime
            newTask.isCompleted = false

            self.saveContext()

            DispatchQueue.main.async {
                onSuccess()
            }
        }
    }


    // MARK: - Update Task
    func updateTask(task: ToDoEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
            fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, task.id as CVarArg)
            
            do {
                let tasks = try self.context.fetch(fetchRequest)
                if let taskToUpdate = tasks.first {
                    taskToUpdate.title = task.title
                    taskToUpdate.details = task.details
                    taskToUpdate.startTime = task.startTime
                    taskToUpdate.endTime = task.endTime
                    taskToUpdate.isCompleted = task.isCompleted

                    self.saveContext()

                    DispatchQueue.main.async {
                        onSuccess()
                    }
                } else {
                    print("Task not found")
                    DispatchQueue.main.async {
                        onFailure(nil)
                    }
                }
            } catch {
                print("Failed to update task: \(error)")
                DispatchQueue.main.async {
                    onFailure(error)
                }
            }
        }
    }


    // MARK: - Delete Task
    func deleteTask(task: ToDoEntity, completion: @escaping () -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            let fetchRequest = ToDoTask.fetchRequest() as! NSFetchRequest<ToDoTask>
            fetchRequest.predicate = NSPredicate(format: Constants.idPredicateFormat, task.id as CVarArg)

            do {
                if let taskToDelete = try self.context.fetch(fetchRequest).first {
                    self.context.delete(taskToDelete)
                    self.saveContext()
                } else {
                    print("Task not found")
                }
            } catch {
                print("Failed to delete task: \(error)")
            }

            DispatchQueue.main.async { completion() }
        }
    }

    // MARK: - Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
