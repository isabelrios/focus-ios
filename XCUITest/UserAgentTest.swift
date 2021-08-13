/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class UserAgentTest: BaseTestCase {

    func testSignInWithGoogle() {
        loadWebPage("https://getpocket.com/")
        let btn = app.links["Sign up with Google"]
        waitForExistence(btn)
        btn.tap()
        waitForWebPageLoad()
        waitForNoExistence(app.webViews.staticTexts["Error: disallowed_useragent"])
    }
}
