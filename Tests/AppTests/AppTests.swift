@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    func testApplicationIsConfigured() throws {
        let application = Application(.testing)
        defer { application.shutdown() }
        try configure(application)

        try application.test(.GET, "/") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
}
