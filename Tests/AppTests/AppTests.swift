@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    func testApplicationIsConfigured() throws {
        let application = Application(.testing)
        defer { application.shutdown() }
        try configure(application)

        try application.test(.GET, "/", beforeRequest: beforeRequest) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    private func beforeRequest(_ request: inout XCTHTTPRequest) throws {
        request.headers.basicAuthorization = BasicAuthorization(username: Environment.process.BASIC_AUTH_USERNAME!, password: Environment.process.BASIC_AUTH_PASSWORD!)
    }
    
}
