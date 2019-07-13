//
//  JsonTests.swift
//  RequestTests
//
//  Created by Carson Katri on 7/12/19.
//

import XCTest
import Combine
@testable import Json

class JsonTests: XCTestCase {
    func testBuild() {
        self.measure {
            _ = Json {
                JsonProperty(key: "firstName", value: "Carson")
            }
        }
    }
    
    func testBuildComplex() {
        self.measure {
            _ = Json {
                JsonProperty(key: "firstName", value: "Carson")
                JsonProperty(key: "lastName", value: "Katri")
                JsonProperty(key: "likes", value: ["programming", "swiftui", "webdev"])
                JsonProperty(key: "isEmployed", value: true)
                JsonProperty(key: "projects", value: [
                    Json {
                        JsonProperty(key: "name", value: "swift-request")
                        JsonProperty(key: "description", value: "Make requests in Swift the declarative way.")
                    },
                    Json {
                        JsonProperty(key: "name", value: "CardKit")
                        JsonProperty(key: "description", value: "iOS 11 Cards in Swift")
                    }
                ])
            }
        }
    }
    
    func testEncode() {
        let json = Json {
            JsonProperty(key: "firstName", value: "Carson")
            JsonProperty(key: "lastName", value: "Katri")
        }
        let string = json.string.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        XCTAssertTrue(string == "{\"firstName\":\"Carson\",\"lastName\":\"Katri\"}" || string == "{\"lastName\":\"Katri\",\"firstName\":\"Carson\"}")
    }
    
    func testEncodePerformance() {
        self.measure {
            _ = Json {
                JsonProperty(key: "firstName", value: "Carson")
                JsonProperty(key: "lastName", value: "Katri")
            }.string
        }
    }
    
    func testParse() {
        let json = Json.Parse("{\"firstName\":\"Carson\",\"lastName\":\"Katri\"}")!
        XCTAssertTrue(json["firstName"].string == "Carson" && json["lastName"].string == "Katri")
    }
    
    func testParsePerformance() {
        self.measure {
            _ = Json.Parse("{\"firstName\":\"Carson\",\"lastName\":\"Katri\"}")
        }
    }
    
    func testParseComplex() {
        self.measure {
            _ = Json.Parse(
"""
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
             "description": "Make requests in Swift the declarative way."
         },
         {
             "name": "CardKit",
             "description": "iOS 11 Cards in Swift"
         },
     ]
}
""")
        }
    }
    
    static var allTests = [
        ("build", testBuild),
        ("buildComplex", testBuildComplex),
        ("encode", testEncode),
        ("encodePerformance", testEncodePerformance),
        ("parse", testParse),
        ("parsePerformance", testParsePerformance),
        ("parseComplex", testParseComplex),
    ]

}
