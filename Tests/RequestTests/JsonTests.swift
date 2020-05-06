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
        guard var json = try? Json(complexJson) else {
            XCTAssert(false)
            return
        }
        let subscripts: [JsonSubscript] = ["projects", 0, "codeCov"]
        
        json[] = 0

        XCTAssertEqual(json["isEmployed"].bool, true)
        json["isEmployed"] = false
        XCTAssertEqual(json["isEmployed"].bool, false)

        XCTAssertEqual(json["projects", 0, "stars"].int, 91)
        json["projects", 0, "stars"] = 10
        XCTAssertEqual(json["projects", 0, "stars"].int, 10)

        XCTAssertEqual(json[subscripts].double, 0.98)
        json[subscripts] = 0.49
        XCTAssertEqual(json[subscripts].double, 0.49)

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
            json.projects[1].passing.bool as Any,
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
        json.projects[0].stars = 100
        json.likes = ["Hello", "World"]
        json.projects[1] = ["name" : "hello", "description" : "world"]
        XCTAssertEqual(json["firstName"].string, "Cameron")
        XCTAssertEqual(json["projects"][0].stars.int, 100)
        XCTAssertEqual(json["likes"][0].string, "Hello")
        XCTAssertEqual(json["likes"][1].string, "World")
        XCTAssertEqual(json["projects"][1]["name"].string, "hello")
    }
    
    func testStringify() {
        let _ = Json(["title": "hello", "subtitle": "world"]).data
        guard let stringified = Json(["title": "hello", "subtitle": 1]).stringified else {
            XCTAssert(false)
            return
        }
        XCTAssert(stringified == #"{"title":"hello","subtitle":1}"# || stringified == #"{"subtitle":1,"title":"hello"}"#)
    }
    
    func testMeasureStringify() {
        self.measure {
            let _ = Json(["title": "hello", "subtitle": 1]).stringified
        }
    }
    
    static var allTest = [
        ("parse", testParse),
        ("measureParse", testMeasureParse),
        ("subscripts", testSubscripts),
        ("accessors", testAccessors),
        ("set", testSet),
        ("stringify", testStringify),
        ("measureStringify", testMeasureStringify),
    ]

}
