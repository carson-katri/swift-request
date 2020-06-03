import XCTest
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

    func testRequestWithCondition() {
        let condition = true
        performRequest(Request {
            if condition {
                Url(protocol: .https, url: "jsonplaceholder.typicode.com/todos")
            }
            if !condition {
                Url("invalidurl")
            }
        })
    }

    func testPost() {
        // Workaround for 'ambiguous reference' error.
        let method = Method(.post)
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            method
            Body([
                "title": "My Post",
                "completed": true,
                "userId": 3,
            ])
            Body("{\"userId\" : 3,\"title\" : \"My Post\",\"completed\" : true}")
        })
    }
    
    func testQuery() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.get)
            Query(["userId":"1", "password": "2"])
            Query([QueryParam("key", value: "value"), QueryParam("key2", value: "value2")])
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

    func testHeaders() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Header.Any(key: "Custom-Header", value: "value123")
            Header.Accept(.json)
            Header.Accept("text/html")
            Header.Authorization(.basic(username: "carsonkatri", password: "password123"))
            Header.Authorization(.bearer("authorizationToken"))
            Header.CacheControl(.maxAge(1000))
            Header.CacheControl(.maxStale(1000))
            Header.CacheControl(.minFresh(1000))
            Header.ContentLength(0)
            Header.ContentType(.xml)
            Header.Host("jsonplaceholder.typicode.com")
            Header.Origin("www.example.com")
            Header.Referer("redirectfrom.example.com")
            Header.UserAgent(.firefoxMac)
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

    func testString() {
        let expectation = self.expectation(description: #function)
        var response: String? = nil
        var error: Data? = nil

        _ = Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err.error
            expectation.fulfill()
        }
        .onString { result in
            response = result
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

    func testJson() {
        let expectation = self.expectation(description: #function)
        var response: Json? = nil
        var error: Data? = nil

        _ = Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err.error
            expectation.fulfill()
        }
        .onJson { result in
            response = result
            expectation.fulfill()
        }
        .call()
        waitForExpectations(timeout: 10000)
        if error != nil {
            XCTAssert(false)
        } else if let response = response, response.count > 0 {
            XCTAssert(true)
        }
    }

    func testRequestGroup() {
        let expectation = self.expectation(description: #function)
        var loaded: Int = 0
        var datas: Int = 0
        var strings: Int = 0
        var jsons: Int = 0
        var errors: Int = 0
        let numberOfResponses = 10
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
            Request {
                Url("invalidURL")
            }
        }
        .onData { (index, data) in
            if data != nil {
                loaded += 1
                datas += 1
            }
            if loaded >= numberOfResponses {
                expectation.fulfill()
            }
        }
        .onString { (index, string) in
            if string != nil {
                loaded += 1
                strings += 1
            }
            if loaded >= numberOfResponses {
                expectation.fulfill()
            }
        }
        .onJson { (index, json) in
            if json != nil {
                loaded += 1
                jsons += 1
            }
            if loaded >= numberOfResponses {
                expectation.fulfill()
            }
        }
        .onError({ (index, error) in
            loaded += 1
            errors += 1
            if loaded >= numberOfResponses {
                expectation.fulfill()
            }
        })
        .call()
        waitForExpectations(timeout: 10000)
        XCTAssertEqual(loaded, numberOfResponses)
        XCTAssertEqual(datas, 3)
        XCTAssertEqual(strings, 3)
        XCTAssertEqual(jsons, 3)
        XCTAssertEqual(errors, 1)
    }
    
    func testRequestChain() {
        let expectation = self.expectation(description: #function)
        var success = false
        RequestChain {
            Request.chained { (data, err) in
                Url("https://jsonplaceholder.typicode.com/todos")
                Method(.get)
            }
            Request.chained { (data, err) in
                let json = try? Json(data[0]!)
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

    func testRequestChainErrors() {
        let expectation = self.expectation(description: #function)
        var success = false
        RequestChain {
            Request.chained { (data, err) in
                Url("invalidurl")
            }
            Request.chained { (data, err) in
                Url("https://jsonplaceholder.typicode.com/thispagedoesnotexist")
            }
        }
        .call { (data, errors) in
            if errors.count == 2 {
                success = true
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10000)
        XCTAssert(success)
    }
    
    func testAnyRequest() {
        let expectation = self.expectation(description: #function)
        var success = false
        
        struct Todo: Codable {
            let title: String
            let completed: Bool
            let id: Int
            let userId: Int
        }
        
        AnyRequest<[Todo]> {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onObject { todos in
            success = true
            expectation.fulfill()
        }
        .onError { err in
            expectation.fulfill()
        }
        .call()
        waitForExpectations(timeout: 10000)
        XCTAssert(success)
    }
    
    func testError() {
        let expectation = self.expectation(description: #function)
        var success = false
        
        Request {
            Url("https://jsonplaceholder.typicode./todos")
        }
        .onError { err in
            print(err)
            success = true
            expectation.fulfill()
        }
        .call()
        waitForExpectations(timeout: 10000)
        XCTAssert(success)
    }

    func testUpdate() {
        let expectation = self.expectation(description: #function)
        var numResponses = 0

        Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .update(every: 1)
        .onData { data in
                numResponses += 1
                if numResponses >= 3 {
                    expectation.fulfill()
                }
        }
        .call()
        waitForExpectations(timeout: 10000)
    }

    static var allTests = [
        ("simpleRequest", testSimpleRequest),
        ("post", testPost),
        ("query", testQuery),
        ("complexRequest", testComplexRequest),
        ("headers", testHeaders),
        ("onObject", testObject),
        ("onString", testString),
        ("onJson", testJson),
        ("requestGroup", testRequestGroup),
        ("requestChain", testRequestChain),
        ("requestChainErrors", testRequestChainErrors),
        ("anyRequest", testAnyRequest),
        ("testError", testError),
        ("testUpdate", testUpdate),
    ]
}
