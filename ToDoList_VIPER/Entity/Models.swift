//
//  Models.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation


enum ToDoFilter: String, CaseIterable {
    case all = "Все"
    case open = "Активные"
    case closed = "Завершенные"
}


enum ToDoSortOrder {
    case newestFirst
    case oldestFirst
    case alphabeticalAZ
    case alphabeticalZA
}
