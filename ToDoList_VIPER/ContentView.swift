//
//  ContentView.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @ObservedObject var presenter: ToDoPresenter
    @State private var selectedFilter: ToDoFilter = .all
    @State private var showNewTaskForm: Bool = false
    @State private var editingTask: ToDoEntity? = nil

    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"

        let dateString = formatter.string(from: Date())
        return dateString.prefix(1).uppercased() + dateString.dropFirst()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(
                formattedDate: formattedCurrentDate,
                showNewTaskForm: $showNewTaskForm,
                editingTask: $editingTask,
                presenter: presenter
            )

            HStack {
                ToDoFilterView(
                    selectedFilter: $selectedFilter,
                    allCount: presenter.tasks.count,
                    openCount: presenter.tasks.filter { !$0.isCompleted }.count,
                    closedCount: presenter.tasks.filter { $0.isCompleted }.count
                )
                Spacer()
                MenuView(presenter: presenter)
            }

            ToDoListView(
                presenter: presenter,
                selectedFilter: $selectedFilter,
                showNewTaskForm: $showNewTaskForm,
                editingTask: $editingTask
            )
        }
        .background(Constants.backgroundColor)
    }
}

private enum Constants {
    static let backgroundColor = Color(UIColor.systemGroupedBackground)
}

#Preview {
    let interactor = ToDoInteractor()
    let presenter = ToDoPresenter(interactor: interactor, router: ToDoRouter())
    ContentView(presenter: presenter)
}
