//
//  NifflerUITests.swift
//  NifflerUITests
//
//  Created by dusoltsev on 06.05.2025.
//

import XCTest

final class NifflerUITests: XCTestCase {

    @MainActor
    func testSignUp() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.staticTexts["Create new account"].tap()
        let userNameInput = app.textFields.matching(identifier: "userNameTextField").element(boundBy: 0)
        userNameInput.tap()
        let userName = UUID().uuidString
        userNameInput.typeText(userName)
        let pwd = app.secureTextFields.matching(identifier: "passwordTextField").element(boundBy: 0)
        pwd.tap()
        pwd.typeText("12345")
        app.secureTextFields["confirmPasswordTextField"].tap()
        app.secureTextFields["confirmPasswordTextField"].typeText("12345")
        app.buttons["Sign Up"].tap()
        XCTAssertTrue(app.staticTexts["Congratulations!"].isHittable)
        XCTAssertTrue(app.staticTexts[" You've registered!"].isHittable)
    }
    
    func testTransferCredentialsToRegisterScreen() throws {
        let app = XCUIApplication()
        app.launch()
        
        let userName = UUID().uuidString
        app.textFields["userNameTextField"].tap()
        app.textFields["userNameTextField"].typeText(userName)
        app.secureTextFields["passwordTextField"].tap()
        app.secureTextFields["passwordTextField"].typeText("12345")
        app.staticTexts["Create new account"].tap()
        
        XCTAssertEqual(app.textFields.matching(identifier: "userNameTextField").element(boundBy: 0).value as? String, userName)
        app.buttons.matching(identifier: "passwordTextField").element(boundBy: 0).tap()
        XCTAssertEqual(app.textFields["passwordTextField"].value as? String, "12345")
    }
}
