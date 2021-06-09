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
    var subscriptions: Set<AnyCancellable> = []
    
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
            
        }).store(in: &subscriptions)
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
    
    func testDeveloperMessage() {
        let handler = DeveloperMessage()
        let devMessageExpectation = expectation(description: "DevMessage")
        handler.developerMessage().receive(on: RunLoop.main).sink(receiveCompletion: { completion in
            switch completion {
            case.failure(let error): XCTFail("Failure with error: \(error)")
            case .finished: print("finished")
            }
        }, receiveValue: { message in
            XCTAssertNotNil(message.uSurfMessage)
            XCTAssertNotNil(message.uTimeMessage)
            XCTAssertNotNil(message.uTimeMessage?.announcementNumber)
            devMessageExpectation.fulfill()
        }).store(in: &subscriptions)
        
        waitForExpectations(timeout: 5)
    }
    
    func testLegacyDeveloperMessage() {
        let handler = DeveloperMessage()
        let devMessageexpectation = expectation(description: "DevMessage")
        handler.legacyDeveloperMessage { message in
            XCTAssertNotNil(message.uSurfMessage?.announcementNumber)
            XCTAssertNotNil(message.uSurfMessage?.message)
            XCTAssertNotNil(message.uSurfMessage?.messageActive)
            devMessageexpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

}
