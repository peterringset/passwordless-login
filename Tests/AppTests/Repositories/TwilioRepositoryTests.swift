import Vapor
import XCTest

@testable import App

final class TwilioRepositoryTests: XCTestCase {
    
    private var app: Application!
    private var client: MockClient!
    private var repository: TwilioRepository!
    
    override func setUp() {
        app = Application(.testing)
        client = MockClient(EmbeddedEventLoop())
        app.clients.use { _ in self.client }
        
        repository = TwilioAPIRepository(client: app.client, twilioConfig: TwilioConfig(accountSID: "abcdefghijkl", authToken: "mnopqrstuvw", phoneNumber: "+123456789"))
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testLatestMessage() {
        let expectation = XCTestExpectation(description: "latest message")
        var message: Message?
        repository.latestMessage().whenSuccess {
            message = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(message?.body, "Testing body")
        
    }
    
    func testAuthorization() {
        let expectation = XCTestExpectation(description: "authorization")
        repository.latestMessage().whenSuccess { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        let headers = client.sentRequest?.headers
        let credentials = "Basic YWJjZGVmZ2hpamtsOm1ub3BxcnN0dXZ3"
        XCTAssertEqual(headers?.first(name: .authorization), credentials)
    }
    
}

private class MockClient: Client {
    
    let eventLoop: EventLoop
    
    init(_ eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func delegating(to eventLoop: EventLoop) -> Client {
        return MockClient(eventLoop)
    }

    var sentRequest: ClientRequest?
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
        sentRequest = request
        let data = """
        {
           "messages": [
              {
                 "date_sent": "Fri, 13 Aug 2010 01:16:22 +0000",
                 "body": "Testing body"
              }
           ]
        }
        """
        let buffer = ByteBuffer(data: data.data(using: .utf8)!)
        let response = ClientResponse(status: .ok, headers: [:], body: buffer)
        return eventLoop.makeSucceededFuture(response)
    }

}
