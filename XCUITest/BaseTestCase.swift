/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class BaseTestCase: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["testMode", "disableFirstRunUI"]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    //If it is a first run, first run window should be gone
    func dismissFirstRunUI() {
        let firstRunUI = XCUIApplication().buttons["OK, Got It!"]
        let onboardingUI = XCUIApplication().buttons["Skip"]

        if (firstRunUI.exists) {
            firstRunUI.tap()
        }

        if (onboardingUI.exists) {
            onboardingUI.tap()
        }
    }

    func waitForEnable(_ element: XCUIElement, timeout: TimeInterval = 5.0, file: String = #file, line: UInt = #line) {
        waitFor(element, with: "exists == enable", timeout: timeout, file: file, line: line)
    }

    func waitForExistence(_ element: XCUIElement, timeout: TimeInterval = 5.0, file: String = #file, line: UInt = #line) {
            waitFor(element, with: "exists == true", timeout: timeout, file: file, line: line)
    }

    func waitForHittable(_ element: XCUIElement, timeout: TimeInterval = 5.0, file: String = #file, line: UInt = #line) {
            waitFor(element, with: "isHittable == true", timeout: timeout, file: file, line: line)
    }

    func waitForNoExistence(_ element: XCUIElement, timeoutValue: TimeInterval = 5.0, file: String = #file, line: UInt = #line) {
           waitFor(element, with: "exists != true", timeout: timeoutValue, file: file, line: line)
    }

    func waitForValueContains(_ element: XCUIElement, value: String, file: String = #file, line: UInt = #line) {
            waitFor(element, with: "value CONTAINS '\(value)'", file: file, line: line)
        }

    private func waitFor(_ element: XCUIElement, with predicateString: String, description: String? = nil, timeout: TimeInterval = 5.0, file: String, line: UInt) {
            let predicate = NSPredicate(format: predicateString)
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
            let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
            if result != .completed {
                let message = description ?? "Expect predicate \(predicateString) for \(element.description)"
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: false)
            }
        }


    func iPad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }

    func search(searchWord: String, waitForLoadToFinish: Bool = true) {
        let app = XCUIApplication()

        let searchOrEnterAddressTextField = app.textFields["Search or enter address"]
        waitForHittable(searchOrEnterAddressTextField)

        UIPasteboard.general.string = searchWord

        // Must press this way in order to support iPhone 5s
        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.coordinate(withNormalizedOffset: CGVector.zero).withOffset(CGVector(dx: 10, dy: 0)).press(forDuration: 1.5)
        waitForExistence(app.menuItems["Paste & Go"])
        app.menuItems["Paste & Go"].tap()

        if waitForLoadToFinish {
            let finishLoadingTimeout: TimeInterval = 30
            let progressIndicator = app.progressIndicators.element(boundBy: 0)
            waitFor(progressIndicator,
                    with: "exists != true",
                    description: "Problem loading \(searchWord)",
                timeout: finishLoadingTimeout)
        }
    }

    func loadWebPage(_ url: String, waitForLoadToFinish: Bool = true) {
        let app = XCUIApplication()
        app.textFields["URLBar.urlText"].tap()
        app.textFields["URLBar.urlText"].typeText(url+"\n")

        if waitForLoadToFinish {
            let finishLoadingTimeout: TimeInterval = 30
            let progressIndicator = app.progressIndicators.element(boundBy: 0)
            waitFor(progressIndicator,
                    with: "exists != true",
                    description: "Problem loading \(url)",
                    timeout: finishLoadingTimeout)
        }
    }

    private func waitFor(_ element: XCUIElement, with predicateString: String, description: String? = nil, timeout: TimeInterval = 5.0) {
        let predicate = NSPredicate(format: predicateString)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        if result != .completed {
            let message = description ?? "Expect predicate \(predicateString) for \(element.description)"
            print(message)
        }
    }

    func checkForHomeScreen() {
        waitForExistence(app.buttons["Settings"])
    }

    func waitForWebPageLoad () {
        let app = XCUIApplication()
        let finishLoadingTimeout: TimeInterval = 30
        let progressIndicator = app.progressIndicators.element(boundBy: 0)

        expectation(for: NSPredicate(format: "exists != true"), evaluatedWith: progressIndicator, handler: nil)
        waitForExpectations(timeout: finishLoadingTimeout, handler: nil)
    }
}
