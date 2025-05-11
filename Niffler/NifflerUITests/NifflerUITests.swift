//
//  NifflerUITests.swift
//  NifflerUITests
//
//  Created by dusoltsev on 06.05.2025.
//

import XCTest

final class NifflerUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        runUnauthorizedApplication()
    }

   
    
    func testUserSignUp() throws {
        pressCreateNewAccountButton()
        
        input(login: UUID().uuidString)
        input(password: "12345")
        input(confirmedPassword: "12345")
        pressSignUpButton()
       
        assertSuccessUserRegistration()
    }
    
    func testPrefillCredentialsOnRegisterScreen() throws {
        let userName = UUID().uuidString
        
        input(login: userName)
        input(password: "12345")
        
        pressCreateNewAccountButton()
        
        assertPrefilledLoginPassword(userName, "12345")
    }
    
   
    
    private func runUnauthorizedApplication() {
        XCTContext.runActivity(named: "Launch app without auth") { _ in
            app = XCUIApplication()
            app.launchArguments = ["RemoveAuthOnStart"]
            app.launch()
        }
    }
    
    private func input(login: String) {
        XCTContext.runActivity(named: "Enter login '\(login)'") { _ in
            let loginInput = app.textFields.matching(identifier: "userNameTextField").firstMatch
            loginInput.tap()
            loginInput.typeText(login)
        }
    }
    
    private func input(password: String) {
        XCTContext.runActivity(named: "Enter password '\(password)'") { _ in
            let passwordInput = app.secureTextFields.matching(identifier: "passwordTextField").firstMatch
            passwordInput.tap()
            passwordInput.typeText(password)
        }
    }
    
    private func input(confirmedPassword: String) {
        XCTContext.runActivity(named: "Enter confirmed password '\(confirmedPassword)'") { _ in
            let passwordInput = app.secureTextFields.matching(identifier: "confirmPasswordTextField").firstMatch
            passwordInput.tap()
            passwordInput.typeText(confirmedPassword)
        }
    }
    
    private func pressCreateNewAccountButton() {
        XCTContext.runActivity(named: "Press button 'Create new account'") { _ in
            app.hideKeyboardIfPresent()
            app.staticTexts["Create new account"].tap()
        }
    }
    
    private func pressSignUpButton() {
        XCTContext.runActivity(named: "Press button 'Create new account'") { _ in
            app.buttons["Sign Up"].tap()
        }
    }
    
    private func assertLoginField(_ expectedLogin: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Assert that login has value '\(expectedLogin)'") { _ in
            let inputLogin = app.textFields.matching(identifier: "userNameTextField").firstMatch
            XCTAssertEqual(inputLogin.value as? String, expectedLogin,
                           "Login field value is wrong",
                           file: file,
                           line: line)
        }
    }
    
    private func assertPasswordField(_ password: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Assert that password has value '\(password)'") { _ in
            app.buttons.matching(identifier: "passwordTextField").firstMatch.tap()
            XCTAssertEqual(app.textFields["passwordTextField"].value as? String, password,
                           "Password field value is wrong",
                           file: file,
                           line: line)
        }
    }
    
    private func assertPrefilledLoginPassword(_ login: String, _ password: String, file: StaticString = #filePath, line: UInt = #line) {
        assertPasswordField(password, file: file, line: line)
        assertLoginField(login, file: file, line: line)
    }
    
    private func assertSuccessUserRegistration(file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Assert that user is registered") { _ in
            XCTAssertTrue(app.staticTexts[" You've registered!"].isHittable,
                          "Success message after registration doesn't appear",
                          file: file,
                          line: line)
        }
    }

}

extension XCUIApplication {
    func hideKeyboardIfPresent(fallbackTapElementIdentifier: String? = nil) {
        let keyboard = self.keyboards.element
        guard keyboard.exists else { return }

        // Попытка нажать кнопки на клавиатуре
        if keyboard.buttons["Done"].exists {
            keyboard.buttons["Done"].tap()
        } else if keyboard.buttons["Return"].exists {
            keyboard.buttons["Return"].tap()
        } else if self.toolbars.buttons["Hide Keyboard"].exists {
            // Для iPad — кнопка скрытия клавиатуры
            self.toolbars.buttons["Hide Keyboard"].tap()
        } else if let elementId = fallbackTapElementIdentifier, self.otherElements[elementId].exists {
            // Фолбэк — тап по элементу, чтобы скрыть клавиатуру
            self.otherElements[elementId].tap()
        } else {
            // Если всё остальное не сработало — попытка тапнуть в первое попавшееся безопасное место
            self.otherElements.firstMatch.tap()
        }
    }
}
