//
//  TripsAPIServicesTest.swift
//  MiAguilaDemoTests
//
//  Created by Rafael Andres Amezquita Mejia on 6/20/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import XCTest
@testable import MiAguilaDemo

class TripsAPIServicesTest: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testTripsAPIServices_dataShouldBeNotNil() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let expectation = self.expectation(description: "trips call")
    TripsAPIServicesManager.getTrips { (data) in
      XCTAssertNotNil(data)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testTripsAdapter_tripsObjectShouldBeNotNil() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let adapter = TripsAdapter()
    let expectation = self.expectation(description: "trips call")
    adapter.getTrips { (trips) in
      XCTAssertNotNil(trips)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
}
