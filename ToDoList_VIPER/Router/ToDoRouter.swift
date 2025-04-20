//
//  ToDoRouter.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import SwiftUI


struct ToDoModuleBuilder {
    static func createModule() -> some View {
        let interactor = ToDoInteractor()
        let router = ToDoRouter() // Создаем роутер
        let presenter = ToDoPresenter(interactor: interactor, router: router) // Передаем роутер презентеру
        
        return ContentView(presenter: presenter)
    }
}



final class ToDoRouter: ObservableObject, ToDoRouterProtocol {
    @Published var showTaskDetail = false
    var selectedTask: ToDoEntity?

    func navigateToTaskDetail(task: ToDoEntity) {
        selectedTask = task
        showTaskDetail = true
    }
}
