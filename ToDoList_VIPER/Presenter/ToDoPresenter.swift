//
//  ToDoPresenter.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation


final class ToDoPresenter: ToDoPresenterProtocol, ObservableObject {
    @Published var tasks: [ToDoEntity] = []
    private let interactor: ToDoInteractorProtocol
    let router: ToDoRouterProtocol

    private var sortOrder: ToDoSortOrder = .newestFirst
    private enum Constants {
        static let userDefaultsKey = "hasLoadedTasksFromAPI"
    }
    
    
   
    init(interactor: ToDoInteractorProtocol, router: ToDoRouterProtocol) {
        self.interactor = interactor
        self.router = router // Инициализация роутера
        loadTasks()
    }
    
    
    
    func openTaskDetail(task: ToDoEntity) {
           router.navigateToTaskDetail(task: task)
       }
    
    func loadTasks() {
        let hasLoadedTasksFromAPI = UserDefaults.standard.bool(forKey: Constants.userDefaultsKey)
        
        if hasLoadedTasksFromAPI {
            interactor.fetchTasks { [weak self] tasks in
                DispatchQueue.main.async {
                    self?.sortAndAssignTasks(tasks)
                }
            }
        } else {
            interactor.fetchTasksFromAPI { [weak self] tasks in
                DispatchQueue.main.async {
                    self?.sortAndAssignTasks(tasks)
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultsKey)
                }
            }
        }
    }
    
    
    func addTask(title: String, details: String, startTime: Date?, endTime: Date?, completion: @escaping (Bool) -> Void) {
        interactor.addTask(title: title, details: details, startTime: startTime, endTime: endTime, onSuccess: { [weak self] in
            self?.loadTasks()
            completion(true)
        }, onFailure: { error in
            completion(false)
        })
    }
    
    
    func toggleTaskCompletion(task: ToDoEntity) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()

        interactor.updateTask(task: updatedTask, onSuccess: { [weak self] in
            guard let self = self else { return }
            
            if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[index] = updatedTask
            }

            self.loadTasks()
        }, onFailure: { error in
            print("Failed to toggle task completion: \(error?.localizedDescription ?? "Unknown error")")
        })
    }

   
    func updateTask(task: ToDoEntity, completion: @escaping (Bool) -> Void) {
        interactor.updateTask(task: task, onSuccess: { [weak self] in
            self?.loadTasks()
            completion(true)
        }, onFailure: { error in
            completion(false)
        })
    }
    
    
    func deleteTask(task: ToDoEntity) {
        interactor.deleteTask(task: task) { [weak self] in
            self?.loadTasks()
        }
    }

   
    func changeSortOrder(to newSortOrder: ToDoSortOrder) {
        sortOrder = newSortOrder
        sortAndAssignTasks(tasks)
    }
    
   
    func filteredTasks(for filter: ToDoFilter) -> [ToDoEntity] {
        switch filter {
        case .all:
            return tasks
        case .open:
            return tasks.filter { !$0.isCompleted }
        case .closed:
            return tasks.filter { $0.isCompleted }
        }
    }

   
    private func sortAndAssignTasks(_ tasks: [ToDoEntity]) {
        switch sortOrder {
        case .newestFirst:
            self.tasks = tasks.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            self.tasks = tasks.sorted { $0.createdAt < $1.createdAt }
        case .alphabeticalAZ:
            self.tasks = tasks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .alphabeticalZA:
            self.tasks = tasks.sorted { $0.title.lowercased() > $1.title.lowercased() }
        }
    }
}


