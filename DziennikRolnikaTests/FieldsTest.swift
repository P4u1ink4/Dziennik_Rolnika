

import XCTest
import SwiftUI
import MapKit
@testable import DziennikRolnika

class FieldsTests: XCTestCase {
    
    func testFilteredFieldsWithoutFilters() {
        let viewModel = FieldViewModel()
        let fields: [Field] = [
            Field(location: CLLocationCoordinate2D(latitude: 52.4064, longitude: 16.9252), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05), category: "Category1", history: "History1"),
            Field(location: CLLocationCoordinate2D(latitude: 53.5500, longitude: 9.9937), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05), category: "Category2", history: "History2")
        ]
        viewModel.fields = fields
        
        let fieldsView = Fields(viewModel: viewModel)
        let filteredFields = fieldsView.filteredFields
        
        XCTAssertEqual(filteredFields.count, fields.count)
    }
    
    func testColorManagerSaveAndLoad() {
        let colorManager = ColorManager()
        let color = Color.red
        
        colorManager.selectedColor = color
        colorManager.saveSelectedColor()
        colorManager.loadSelectedColor()
        
        XCTAssertEqual(colorManager.selectedColor, color)
    }
    
    func testFieldViewModelAddField() {
        let viewModel = FieldViewModel()
        let initialcount = viewModel.fields.count
        let field = Field(location: CLLocationCoordinate2D(latitude: 52.4064, longitude: 16.9252), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05), category: "Category1", history: "History1")
        
        viewModel.addField(field)
        
        XCTAssertEqual(viewModel.fields.count, initialcount + 1)
    }
}
