

import XCTest
import SwiftUI
@testable import DziennikRolnika

class ContentViewTests: XCTestCase {
    
    func testAddTask() {
        let tasks = TaskViewModel()
        let initialCount = tasks.tasks.count
        
        tasks.addTask(title: "check")
        
        XCTAssertEqual(tasks.tasks.count,initialCount+1)
    }
    
    func testRemoveTask() {
        let tasks = TaskViewModel()
        let initialCount = tasks.tasks.count
        
        if(initialCount>0){
            tasks.tasks.remove(at: 0)
            XCTAssertEqual(tasks.tasks.count,initialCount-1)
        }
    }
}
