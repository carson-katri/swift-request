//
//  JsonTests.swift
//  RequestTests
//
//  Created by Carson Katri on 7/12/19.
//

import XCTest
import Combine
@testable import Json
@testable import Request

class JsonTests: XCTestCase {
    let complexJson = """
{
    "firstName": "Carson",
    "lastName": "Katri",
    "likes": [
        "programming",
        "swiftui",
        "webdev"
    ],
    "isEmployed": true,
    "projects": [
        {
            "name": "swift-request",
            "description": "Make requests in Swift the declarative way.",
            "stars": 91,
            "passing": true,
            "codeCov": 0.98
        },
        {
            "name": "CardKit",
            "description": "iOS 11 Cards in Swift",
            "stars": 58,
            "passing": null,
            "codeCov": null
        },
    ],
}
"""
    func testParse() {
        guard let _ = try? Json(complexJson) else {
            XCTAssert(false)
            return
        }
        XCTAssert(true)
    }
    
    func testMeasureParse() {
        measure {
            let _ = try? Json(complexJson)
        }
    }
    
    func testSubscripts() {
        guard let json = try? Json(complexJson) else {
            XCTAssert(false)
            return
        }
        let subscripts: [JsonSubscript] = ["projects", 0, "codeCov"]
        let _: [Any] = [
            json.firstName,
            json.projects[0],
            json["projects", 0, "stars"],
            json[subscripts]
        ]
    }
    
    func testAccessors() {
        guard let json = try? Json(complexJson) else {
            XCTAssert(false)
            return
        }
        let _: [Any] = [
            json.firstName.string,
            json.firstName.stringOptional as Any,
            json.likes.array,
            json.likes.arrayOptional as Any,
            json.projects.count,
            json.projects[0].stars.int,
            json.projects[0].stars.intOptional as Any,
            json.projects[0].codeCov.double,
            json.projects[1].codeCov.double,
            json.projects[1].codeCov.doubleOptional as Any,
            json.projects[1].passing.boolOptional as Any,
            json.value,
        ]
        XCTAssert(true)
    }
    
    func testSet() {
        guard var json = try? Json(complexJson) else {
            XCTAssert(false)
            return
        }
        json.firstName = "Cameron"
        json.likes = ["Hello", "World"]
        XCTAssertEqual(json["firstName"].string, "Cameron")
    }
    
    func testStringify() {
        let _ = Json(["title": "hello", "subtitle": "world"]).data
        guard let stringified = Json(["title": "hello", "subtitle": "world"]).stringified else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(stringified, "{\"title\":\"hello\",\"subtitle\":\"world\"}")
    }
    
    func testMeasureStringify() {
        self.measure {
            let _ = Json(["title": "hello", "subtitle": "world"]).stringified
        }
    }
    
    static var allTest = [
        ("parse", testParse),
        ("measureParse", testMeasureParse),
        ("subscripts", testSubscripts),
        ("accessors", testAccessors),
        ("stringify", testStringify),
        ("measureStringify", testMeasureStringify),
    ]

}
