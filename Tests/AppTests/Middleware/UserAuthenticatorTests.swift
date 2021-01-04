import Vapor
import XCTest

@testable import App

class UserAuthenticatorTests: XCTestCase {
    
    var application: Application!
    var authenticator: UserAuthenticator!
    var eventLoop: EventLoop!
    
    override func setUp() {
        application = Application(.testing)
        authenticator = UserAuthenticator(realm: "TestRealm", username: "user", password: "pass")
        eventLoop = EmbeddedEventLoop()
    }
    
    override func tearDown() {
        application.shutdown()
    }
    
    func testSendsChallenge() {
        let request = Request(application: application, method: .GET, url: URI(path: "http://localhost"), on: eventLoop)
        let responder = MockResponder { request in
            self.eventLoop.makeSucceededFuture(Response(status: .unauthorized))
        }
        let response = authenticator.respond(to: request, chainingTo: responder)
        let expectation = XCTestExpectation(description: "sends challenge")
        response.whenSuccess { response in
            XCTAssertEqual(response.status, .unauthorized)
            XCTAssertEqual(response.headers.first(name: "WWW-Authenticate"), #"Basic realm="TestRealm", charset="UTF-8""#)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testSendsError() {
        let request = Request(application: application, method: .GET, url: URI(path: "http://localhost"), on: eventLoop)
        let responder = MockResponder { request in
            self.eventLoop.makeFailedFuture(TestError(status: .unauthorized))
        }
        let response = authenticator.respond(to: request, chainingTo: responder)
        let expectation = XCTestExpectation(description: "sends challenge")
        response.whenSuccess { response in
            XCTAssertEqual(response.status, .unauthorized)
            XCTAssertEqual(response.headers.first(name: "WWW-Authenticate"), #"Basic realm="TestRealm", charset="UTF-8""#)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testAuthenticatesCorrectCredentials() {
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: "user", password: "pass")
        let request = Request(application: application, method: .GET, url: URI(path: "http://localhost"), headers: headers, on: eventLoop)
        let expectation = XCTestExpectation(description: "authenticates")
        let responder = MockResponder { request in
            XCTAssertTrue(request.auth.has(User.self))
            expectation.fulfill()
            return self.eventLoop.makeSucceededFuture(Response(status: .ok))
        }
        _ = authenticator.respond(to: request, chainingTo: responder)
        wait(for: [expectation], timeout: 1)
    }
    
}

private struct TestError: AbortError {
    var status: HTTPResponseStatus
}

private class MockResponder: Responder {

    let responding: (Request) -> EventLoopFuture<Response>

    init(responding: @escaping (Request) -> EventLoopFuture<Response>) {
        self.responding = responding
    }

    func respond(to request: Request) -> EventLoopFuture<Response> {
        responding(request)
    }

}
