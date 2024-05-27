import XCTest
@testable import DziennikRolnika

class CowManagerTests: XCTestCase {

    func testAddCow() {
        let cowManager = CowManager()
        let initialCount = cowManager.cows.count

        cowManager.addCow(identificationNumber: "PL123456789012", birthDate: Date(), breed: "Holstein", lactation: "First", image: nil)

        XCTAssertEqual(cowManager.cows.count, initialCount + 1)
    }
}

