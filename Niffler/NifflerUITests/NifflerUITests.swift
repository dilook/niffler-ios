//
//  NifflerUITests.swift
//  NifflerUITests
//
//  Created by dusoltsev on 06.05.2025.
//

import XCTest
import Fakery

final class NifflerUITests: XCTestCase {
    
    let faker = Faker()
    
    var app: XCUIApplication!
    
    override func setUp() {
        runUnauthorizedApplication()
    }

    
    func testUserSignUp() throws {
        pressCreateNewAccountButton()
        
        signUp(login: UUID().uuidString, password: "12345")
       
        assertSuccessUserRegistration()
        app.scrollViews.buttons["Log in"].tap()
        app.buttons["loginButton"].tap()
        
        assertIsSpendsViewAppeared(spendCount: 0)
    }
    
    func testPrefillCredentialsOnRegisterScreen() throws {
        let userName = UUID().uuidString
        
        input(login: userName)
        input(password: "12345")
        
        pressCreateNewAccountButton()
        
        assertPrefilledLoginPassword(userName, "12345")
    }
    
    func testAddSpend() throws {
        login(username: "Tiggo", password: "12345")
        
        let spendDescription = faker.address.streetName()
        addNewSpend(spendDescription)
        
        assertSpendInList(spendDescription)
    }
    
    private func addNewSpend(_ description: String) {
        XCTContext.runActivity(named: "Adding spend with description: \(description)") { _ in
            app.buttons["addSpendButton"].tap()
            app.textFields["amountField"].tap()
            app.textFields["amountField"].typeText("100")
            app.textFields["descriptionField"].tap()
            app.textFields["descriptionField"].typeText(description)
            if "+ New category" == app.otherElements["Select category"].label {
                app.otherElements["Select category"].tap()
                app.alerts.textFields.firstMatch.tap()
                app.alerts.textFields.firstMatch.typeText(faker.car.brand())
                app.alerts.buttons["Add"].tap()
            }
            app.buttons["Add"].tap()
        }
    }
    
    fileprivate func login(username: String, password: String) {
        XCTContext.runActivity(named: "Logging by \(username)") { _ in
            input(login: username)
            input(password: password)
            app.buttons["loginButton"].tap()
            waitSpendsScreen()
        }
    }
    
    
    private func assertSpendInList(_ description: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Spends screen waiting") { _ in
            waitSpendsScreen()
            XCTAssertTrue(app.otherElements["spendsList"].staticTexts[description].exists,
                           file: file, line: line)
        }
    }
    
    private func assertIsSpendsViewAppeared(spendCount: Int = 1, file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Spends screen waiting") { _ in
            waitSpendsScreen()
            XCTAssertGreaterThanOrEqual(app.otherElements["spendsList"].switches.count,
                                        spendCount,
                                        file: file, line: line)
        }
    }
    
    fileprivate func waitSpendsScreen(file: StaticString = #filePath, line: UInt = #line) {
        let isFound = app.staticTexts["Statistics"].waitForExistence(timeout: 5)
        XCTAssertTrue(isFound,
                      "Spends screen didn't appear",
                      file: file, line: line)
    }
    
    
    private func signUp(login: String, password: String) {
        input(login: login)
        input(password: password)
        input(confirmedPassword: password)
        pressSignUpButton()
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
