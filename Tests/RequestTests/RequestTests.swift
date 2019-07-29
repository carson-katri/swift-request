import XCTest
import SwiftUI
import Combine
import Json
@testable import Request

final class RequestTests: XCTestCase {
    func performRequest(_ request: Request) {
        let expectation = self.expectation(description: #function)
        var response: Data? = nil
        var error: Data? = nil
        request
        .onError { err in
            error = err.error
            expectation.fulfill()
        }
        .onData { data in
            response = data
            expectation.fulfill()
        }.call()
        waitForExpectations(timeout: 10000)
        if error != nil {
            XCTAssert(false)
        } else if response != nil {
            XCTAssert(true)
        }
    }
    
    func testSimpleRequest() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        })
    }
    
    func testPost() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.post)
            Body([
                "title": "My Post",
                "completed": true,
                "userId": 3,
            ])
        })
    }
    
    func testQuery() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.get)
            Query(["userId":"1"])
        })
    }
    
    func testComplexRequest() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.get)
            Query(["userId":"1"])
            Header.CacheControl(.noCache)
        })
    }
    
    func testObject() {
        struct Todo: Decodable {
            let id: Int
            let userId: Int
            let title: String
            let completed: Bool
        }
        
        let expectation = self.expectation(description: #function)
        var response: [Todo]? = nil
        var error: Data? = nil

        _ = AnyRequest<[Todo]> {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err.error
            expectation.fulfill()
        }
        .onObject { (todos: [Todo]?) in
            response = todos
            expectation.fulfill()
        }
        .call()
        waitForExpectations(timeout: 10000)
        if error != nil {
            XCTAssert(false)
        } else if response != nil {
            XCTAssert(true)
        }
    }
    
    func testRequestGroup() {
        let expectation = self.expectation(description: #function)
        var loaded: Int = 0
        RequestGroup {
            Request {
                Url("https://jsonplaceholder.typicode.com/todos")
            }
            Request {
                Url("https://jsonplaceholder.typicode.com/posts")
            }
            Request {
                Url("https://jsonplaceholder.typicode.com/todos/1")
            }
        }
        .onData { (index, data) in
            if data != nil {
                loaded += 1
            }
            if loaded >= 3 {
                expectation.fulfill()
            }
        }
        .call()
        waitForExpectations(timeout: 10000)
        XCTAssertEqual(loaded, 3)
    }
    
    func testRequestChain() {
        let expectation = self.expectation(description: #function)
        var success = false
        RequestChain {
            Request.chained { (data, err) in
                Url("https://jsonplaceholder.typicode.com/todos")
            }
            Request.chained { (data, err) in
                let json = Json.Parse(data[0]!)
                return Url("https://jsonplaceholder.typicode.com/todos/\(json?[0]["id"].int ?? 0)")
            }
        }
        .call { (data, errors) in
            if data.count > 1 {
                success = true
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10000)
        XCTAssert(success)
    }

    static var allTests = [
        ("simpleRequest", testSimpleRequest),
        ("post", testPost),
        ("query", testQuery),
        ("complexRequest", testComplexRequest),
        ("onObject", testObject),
        ("requestGroup", testRequestGroup),
        ("requestChain", testRequestChain),
    ]
}
