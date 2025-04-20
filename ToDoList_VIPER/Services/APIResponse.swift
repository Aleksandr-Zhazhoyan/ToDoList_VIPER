//
//  APIResponse.swift
//  ToDoList_VIPER
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import Foundation


struct APIResponse: Decodable {
    let todos: [APITask]
}



struct APITask: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}
