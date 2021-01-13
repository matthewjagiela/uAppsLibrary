//
//  uAppsInternetTests.swift
//  uAppsLibraryTests
//
//  Created by Matthew Jagiela on 1/13/21.
//

import XCTest
import Combine
@testable import uAppsLibrary
class uAppsInternetTests: XCTestCase {
    
    let handler = InternetLabelsManager()
    var subsciptions: Set<AnyCancellable> = []
    
    func testInternetLabels() {
        let internetExpectation = expectation(description: "InternetLabels")
        handler.fetchLabels().receive(on: RunLoop.main).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error): XCTFail("Failure with error: \(error)")
            case .finished: print("finished")
            }
            
        }, receiveValue: { info in
            XCTAssertNotNil(info.uAppsNews)
            XCTAssertNotNil(info.uTimeVersion)
            XCTAssertNotNil(info.uFailVersion)
            XCTAssertNotNil(info.uSurfVersion)
            internetExpectation.fulfill()
            
        }).store(in: &subsciptions)
        waitForExpectations(timeout: 5)
    }
    
    func testLegacyLabels() {
        let internetExpectation = expectation(description: "InternetLabels")
        handler.legacyFetchLabels { info in
            XCTAssertNotNil(info.uAppsNews)
            XCTAssertNotNil(info.uTimeVersion)
            XCTAssertNotNil(info.uFailVersion)
            XCTAssertNotNil(info.uSurfVersion)
            internetExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

}
