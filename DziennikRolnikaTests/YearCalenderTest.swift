

import XCTest
@testable import DziennikRolnika
import SwiftUI

class YearCalenderTests: XCTestCase {
    
    func testGetDaysOfMonth() {
        let year = 2023
        let month = 8
        let monthView = MonthView(year: year, month: month)
        
        let days = monthView.getDaysOfMonth(year: year, month: month)
        
        XCTAssertEqual(days.count, 31 + 1)
    }
    
    func testGetBackgroundColorForSpecialDay() {
        let month = 7
        let day = 15
        let color = getBackgroundColor(month: month, day: day)
        
        XCTAssertNotEqual(color, Color.clear)
    }
    
    func testGetMonthName() {
        let month = 12 
        
        let monthName = getMonthName(month)
        
        XCTAssertEqual(monthName, "grudzień")
    }
}
