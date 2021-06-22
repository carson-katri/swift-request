import XCTest
import Json
import Combine
@testable import Request

final class RequestTests: XCTestCase {
    func performRequest(_ request: Request) {
        let expectation = self.expectation(description: #function)
        var response: Data? = nil
        var error: Error? = nil
        request
        .onError { err in
            error = err
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
        struct Todo: Codable {
            let title: String
            let completed: Bool
            let userId: Int
        }
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.post)
            Body([
                "title": "My Post",
                "completed": true,
                "userId": 3,
            ])
            Body("{\"userId\" : 3,\"title\" : \"My Post\",\"completed\" : true}")
            RequestBody(Todo(
                title: "My Post",
                completed: true,
                userId: 3
            ))
        })
    }

    func testQuerySingleParams() {
        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.get)
            QueryParam("userId", value: "1")
            QueryParam("password", value: "2")
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

    func testURLConcatenatedStringQuery() {
        let baseUrl = Url(protocol: .https, url: "jsonplaceholder.typicode.com")
        let todosEndpoint = "/todos"

        XCTAssertEqual(baseUrl + todosEndpoint, Url("https://jsonplaceholder.typicode.com/todos"))
    }

    func testURLConcatenatedURLQuery() {
        let baseUrl = Url("https://jsonplaceholder.typicode.com")
        let todosEndpoint = Url("/todos")

        XCTAssertEqual(baseUrl + todosEndpoint, Url("https://jsonplaceholder.typicode.com/todos"))
    }

    func testBuildEitherQuery() {
        enum AuthProvider {
            case explicity(userId: String, password: String)
            case barrer(String)
        }

        let provider = AuthProvider.explicity(userId: "1", password: "2")

        performRequest(Request {
            Url("https://jsonplaceholder.typicode.com/todos")
            Method(.get)

            switch provider {
            case .explicity(let userId, let password):
                Query(["userId":userId, "password": password])
            case .barrer(let token):
                Header.Authorization(.bearer(token))
            }

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
    
    func testStatusCode() {
        let expectation = self.expectation(description: #function)
        let statusCodeExpectation = self.expectation(description: #function+"status")
        var response: String? = nil
        var error: Error? = nil
        var statusCode: Int? = nil
        
        Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err
            expectation.fulfill()
        }
        .onString { result in
            response = result
            expectation.fulfill()
        }
        .onStatusCode { code in
            statusCode = code
            statusCodeExpectation.fulfill()
        }
        .call()
        waitForExpectations(timeout: 10000)
        if error != nil {
            XCTAssert(false)
        } else if statusCode != nil {
            XCTAssert(true)
        } else if response != nil {
            XCTAssert(true)
        }
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
        var error: Error? = nil

        AnyRequest<[Todo]> {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err
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
        var error: Error? = nil

        Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err
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
        var error: Error? = nil

        Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .onError { err in
            error = err
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
        expectation.expectedFulfillmentCount = 3
        expectation.assertForOverFulfill = false
        
        Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .update(every: 1)
        .onData { data in
            expectation.fulfill()
        }
        .call()
        waitForExpectations(timeout: 10000)
    }
    
    func testTimeout() {
        let expectation = self.expectation(description: #function)
        
        Request {
            Url("http://10.255.255.1")
            Timeout(1, for: .all)
        }
        .onError { error in
            if error.localizedDescription == "The request timed out." {
                expectation.fulfill()
            }
        }
        .call()
        
        waitForExpectations(timeout: 2000)
    }
    
    func testPublisher() {
        let expectation = self.expectation(description: #function)
        
        let publisher = Request {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .sink(receiveCompletion: { res in
            switch res {
            case let .failure(err):
                XCTFail(err.localizedDescription)
            case .finished:
                expectation.fulfill()
            }
        }, receiveValue: { _ in })
        XCTAssertNotNil(publisher)
        
        waitForExpectations(timeout: 10000)
    }
    
    func testPublisherDecode() {
        struct Todo: Decodable {
            let id: Int
            let userId: Int
            let title: String
            let completed: Bool
        }
        
        let expectation = self.expectation(description: #function)
        
        let publisher = AnyRequest<[Todo]> {
            Url("https://jsonplaceholder.typicode.com/todos")
        }
        .objectPublisher
        .sink(receiveCompletion: { res in
            switch res {
            case let .failure(err):
                XCTFail(err.localizedDescription)
            case .finished:
                expectation.fulfill()
            }
        }, receiveValue: { todos in
            XCTAssertGreaterThan(todos.count, 1)
        })
        XCTAssertNotNil(publisher)
        
        waitForExpectations(timeout: 10000)
    }
    
    func testPublisherGroup() {
        let expectation = self.expectation(description: #function)
        
        let publisher = RequestGroup {
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
        .sink(receiveCompletion: { res in
            switch res {
            case .finished:
                expectation.fulfill()
            case .failure(let err):
                XCTFail(err.localizedDescription)
            }
        }, receiveValue: { vals in
            XCTAssertEqual(vals.count, 3)
        })
        
        XCTAssertNotNil(publisher)
        
        waitForExpectations(timeout: 10000)
    }

    func testOptionalFormData() {
        let data = "This will result in a optional data".data(using: .utf8)

        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {
                    if let data = data {
                        Form.Data(data, named: "data.txt", withType: .text)
                    }
                }
            }
        )
    }

    func testSwitchFormData() {
        enum Payload {
            case image(Data)
            case cover(Data)
        }

        let payload = Payload.image("this is the user image".data(using: .utf8)!)

        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {
                    switch payload {
                    case .image(let data):
                        Form.Data(data, named: "image.txt", withType: .text)
                    case .cover(let data):
                        Form.Data(data, named: "cover.txt", withType: .text)
                    }
                }
            }
        )
    }

    func testValueFormData() {
        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {
                    Form.Value(key: "name", "test")
                    Form.Value(key: "email", "test@gmail.com")
                    Form.Value(key: "age", 17)
                }
            }
        )
    }

    func testArrayFormData() {
        let text1 = "Hello World!".data(using: .utf8)!
        let text2 = "This is the second line of the document".data(using: .utf8)!

        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {
                    Form.Data(text1, named: "text1.txt", withType: .text)
                    Form.Data(text2, named: "text2.txt", withType: .text)
                }
            }
        )
    }

    func testNestedArrayFormData() {
        let text1 = "Hello World!".data(using: .utf8)!
        let text2 = "This is the second line of the document".data(using: .utf8)!

        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {
                    Form.Data(text1, named: "text1.txt", withType: .text)
                    Form.Data(text2, named: "text2.txt", withType: .text)

                    if true {
                        Form.Data(text1, named: "text3.txt", withType: .text)
                        Form.Data(text2, named: "text4.txt", withType: .text)
                    }

                    Form.Data(text1, named: "text5.txt", withType: .text)
                    Form.Data(text2, named: "text6.txt", withType: .text)
                }
            }
        )
    }

    func testElseFormData() {
        let nilData: Data? = nil

        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {
                    if let data = nilData {
                        Form.Data(data, named: "data.txt", withType: .text)
                    } else {
                        Form.Data(
                            "Empty data sent".data(using: .utf8)!,
                            named: "data.txt",
                            withType: .text
                        )
                    }
                }
            }
        )
    }

    func testEmptyFormData() {
        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form {}
            }
        )
    }

    #if os(iOS) && targetEnvironment(simulator)
    func testSingleFormFile() {
        performRequest(
            Request {
                Url("http://httpbin.org/post")
                Method(.post)

                Form.File(
                    Url("Media/DCIM/100APPLE/IMG_0001.JPG"),
                    withType: .custom("image/jpg")
                )
            }
        )
    }
    #endif
    
    func testPublisherUpdate() {
        let expectation = self.expectation(description: #function)
        var numResponses = 0
        let publisher = Request {
                Url("https://jsonplaceholder.typicode.com/todos")
            }
            .updatePublisher(every: 1)
            .sink(receiveCompletion: { res in
                switch res {
                case let .failure(err):
                    XCTFail(err.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                numResponses += 1
                if numResponses >= 3 {
                    expectation.fulfill()
                }
            })
        XCTAssertNotNil(publisher)
        
        waitForExpectations(timeout: 10000)
    }

    static var allTests = [
        ("simpleRequest", testSimpleRequest),
        ("post", testPost),
        ("query", testQuery),
        ("complexRequest", testComplexRequest),
        ("headers", testHeaders),
        ("onObject", testObject),
        ("onStatusCode", testStatusCode),
        ("onString", testString),
        ("onJson", testJson),
        ("requestGroup", testRequestGroup),
        ("requestChain", testRequestChain),
        ("requestChainErrors", testRequestChainErrors),
        ("anyRequest", testAnyRequest),
        ("testError", testError),
        ("testUpdate", testUpdate),
        
        ("testPublisher", testPublisher),
        ("testPublisherDecode", testPublisherDecode),
        ("testPublisherGroup", testPublisherGroup)
    ]
}
