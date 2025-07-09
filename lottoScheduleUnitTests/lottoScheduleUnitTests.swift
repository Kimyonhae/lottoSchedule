//
//  lottoScheduleUnitTests.swift
//  lottoScheduleUnitTests
//
//  Created by 김용해 on 7/9/25.
//

import XCTest

final class lottoScheduleUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // TODO: 초기에 알림이 added 되어 있는지
    func testNotificationIsScheduled() throws {
        let expectation = XCTestExpectation(description: "Notification scheduled")

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasLottoNotification = requests.contains { $0.identifier == "weekly_check_lotto" }
            XCTAssertTrue(hasLottoNotification, "Lotto weekly check notification should be scheduled.")
            expectation.fulfill()
            #if DEBUG
                print("등록된 알림:")
                for r in requests {
                    print(" - \(r.identifier)")
                }
            #endif
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
