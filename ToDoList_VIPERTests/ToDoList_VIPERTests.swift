//
//  ToDoList_VIPERTests.swift
//  ToDoList_VIPERTests
//
//  Created by Aleksandr Zhazhoyan on 19.04.2025.
//

import XCTest
@testable import ToDoList_VIPER
import Testing

struct ToDoList_VIPERTests {
    
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        final class ToDoPresenterTests: XCTestCase {
            var presenter: ToDoPresenter!
            var mockInteractor: MockToDoInteractor!
            var mockRouter: MockToDoRouter!
            
            override func setUpWithError() throws {
                mockInteractor = MockToDoInteractor()
                mockRouter = MockToDoRouter() // инициализация
                presenter = ToDoPresenter(interactor: mockInteractor, router: mockRouter)  // Вызов
            }
            
            override func tearDownWithError() throws {
                presenter = nil
                mockInteractor = nil
                mockRouter = nil // очистка
            }
            
            func testLoadTasksFromCoreData() {
                // Given
                let expectation = self.expectation(description: "Tasks loaded")
                let task = ToDoEntity(id: UUID(), title: "Task 1", details: "Details 1", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: false)
                mockInteractor.tasks = [task]
                
                // When
                presenter.loadTasks()
                
                DispatchQueue.main.async {
                    // Then
                    XCTAssertTrue(self.mockInteractor.fetchTasksCalled, "fetchTasks should be called")
                    XCTAssertEqual(self.presenter.tasks.count, 1, "Presenter should load one task")
                    XCTAssertEqual(self.presenter.tasks.first?.title, "Task 1", "Task title should match")
                    expectation.fulfill()
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
            
            func testAddTask() {
                // Given
                let expectation = self.expectation(description: "Task added")
                
                // When
                presenter.addTask(title: "New Task", details: "New Details", startTime: nil, endTime: nil) { success in
                    // Then
                    XCTAssertTrue(success, "addTask should succeed")
                    XCTAssertTrue(self.mockInteractor.addTaskCalled, "addTask should be called")
                    expectation.fulfill()
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
            
            func testToggleTaskCompletion() {
                // Given
                let expectation = self.expectation(description: "Task completion toggled")
                let task = ToDoEntity(id: UUID(), title: "Task 1", details: "Details 1", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: false)
                mockInteractor.tasks = [task]
                presenter.loadTasks()
                
                DispatchQueue.main.async {
                    // When
                    self.presenter.toggleTaskCompletion(task: task)
                    
                    DispatchQueue.main.async {
                        // Проверяем, что метод updateTask был вызван
                        XCTAssertTrue(self.mockInteractor.updateTaskCalled, "updateTask should be called")
                        
                        // Проверяем, что задача обновилась в мок-объекте
                        guard let updatedTask = self.mockInteractor.tasks.first else {
                            XCTFail("Task should be present in mockInteractor")
                            return
                        }
                        XCTAssertTrue(updatedTask.isCompleted, "Task in mockInteractor should be marked as completed")
                        
                        // Проверяем, что обновленная задача правильно отразилась в presenter.tasks после загрузки
                        DispatchQueue.main.async {
                            XCTAssertTrue(self.presenter.tasks.first?.isCompleted ?? false, "Task should be marked as completed")
                            expectation.fulfill()
                        }
                    }
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
            
            func testUpdateTask() {
                // Given
                let expectation = self.expectation(description: "Task updated")
                let task = ToDoEntity(id: UUID(), title: "Task 1", details: "Details 1", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: false)
                
                // When
                presenter.updateTask(task: task) { success in
                    // Then
                    XCTAssertTrue(success, "updateTask should succeed")
                    XCTAssertTrue(self.mockInteractor.updateTaskCalled, "updateTask should be called")
                    expectation.fulfill()
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
            
            func testDeleteTask() {
                // Given
                let expectation = self.expectation(description: "Task deleted")
                let task = ToDoEntity(id: UUID(), title: "Task 1", details: "Details 1", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: false)
                mockInteractor.tasks = [task]
                presenter.loadTasks()
                
                DispatchQueue.main.async {
                    // When
                    self.presenter.deleteTask(task: task)
                    
                    // Then
                    XCTAssertTrue(self.mockInteractor.deleteTaskCalled, "deleteTask should be called")
                    expectation.fulfill()
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
            
            func testChangeSortOrder() {
                // Given
                let expectation = self.expectation(description: "Tasks sorted")
                let task1 = ToDoEntity(id: UUID(), title: "Task B", details: "Details B", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: false)
                let task2 = ToDoEntity(id: UUID(), title: "Task A", details: "Details A", createdAt: Date().addingTimeInterval(-100), startTime: nil, endTime: nil, isCompleted: false)
                mockInteractor.tasks = [task1, task2]
                presenter.loadTasks()
                
                DispatchQueue.main.async {
                    print("Tasks before sorting: \(self.presenter.tasks.map { $0.title })")
                    
                    // When
                    self.presenter.changeSortOrder(to: .alphabeticalAZ)
                    
                    print("Tasks after sorting: \(self.presenter.tasks.map { $0.title })")
                    
                    // Then
                    XCTAssertEqual(self.presenter.tasks.first?.title, "Task A", "Tasks should be sorted alphabetically A-Z")
                    expectation.fulfill()
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
            
            func testFilteredTasks() {
                // Given
                let expectation = self.expectation(description: "Tasks filtered")
                let task1 = ToDoEntity(id: UUID(), title: "Task A", details: "Details A", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: false)
                let task2 = ToDoEntity(id: UUID(), title: "Task B", details: "Details B", createdAt: Date(), startTime: nil, endTime: nil, isCompleted: true)
                mockInteractor.tasks = [task1, task2]
                presenter.loadTasks()
                
                DispatchQueue.main.async {
                    print("All tasks: \(self.presenter.tasks.map { "\($0.title) - \($0.isCompleted ? "Completed" : "Open")" })")
                    
                    // When
                    let openTasks = self.presenter.filteredTasks(for: .open)
                    let closedTasks = self.presenter.filteredTasks(for: .closed)
                    
                    print("Open tasks: \(openTasks.map { $0.title })")
                    print("Closed tasks: \(closedTasks.map { $0.title })")
                    
                    // Then
                    XCTAssertEqual(openTasks.count, 1, "There should be one open task")
                    XCTAssertEqual(closedTasks.count, 1, "There should be one closed task")
                    expectation.fulfill()
                }
                
                waitForExpectations(timeout: 1.0, handler: nil)
            }
        }
        
        class MockToDoInteractor: ToDoInteractorProtocol {
            var tasks: [ToDoEntity] = []
            var fetchTasksCalled = false
            var addTaskCalled = false
            var updateTaskCalled = false
            var deleteTaskCalled = false
            
            func fetchTasks(completion: @escaping ([ToDoEntity]) -> Void) {
                fetchTasksCalled = true
                completion(tasks)
            }
            
            func fetchTasksFromAPI(completion: @escaping ([ToDoEntity]) -> Void) {
                fetchTasksCalled = true
                completion(tasks)
            }
            
            func addTask(title: String, details: String, startTime: Date?, endTime: Date?, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
                addTaskCalled = true
                let newTask = ToDoEntity(id: UUID(), title: title, details: details, createdAt: Date(), startTime: startTime, endTime: endTime, isCompleted: false)
                tasks.append(newTask)
                onSuccess()
            }
            
            func updateTask(task: ToDoEntity, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
                updateTaskCalled = true
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task
                }
                onSuccess()
            }
            
            func deleteTask(task: ToDoEntity, completion: @escaping () -> Void) {
                deleteTaskCalled = true
                tasks.removeAll { $0.id == task.id }
                completion()
            }
        }
        
        
        class MockToDoRouter: ToDoRouterProtocol {
            var navigateCalled = false
            var passedTask: ToDoEntity?
            
            func navigateToTaskDetail(task: ToDoEntity) {
                navigateCalled = true
                passedTask = task
            }
        }
        
    }
    
}
