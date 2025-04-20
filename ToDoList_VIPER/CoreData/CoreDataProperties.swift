//
//  CoreDataProperties.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation
import CoreData

extension ToDoTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoTask> {
        return NSFetchRequest<ToDoTask>(entityName: "ToDoTask")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var details: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var isCompleted: Bool
}

extension ToDoTask: Identifiable { }
