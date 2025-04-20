//
//  ToDoEntity.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation

struct ToDoEntity: Identifiable {
    let id: UUID
    var title: String
    var details: String
    let createdAt: Date
    var startTime: Date?
    var endTime: Date?
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, details: String, createdAt: Date = Date(), startTime: Date? = nil, endTime: Date? = nil, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }
}
