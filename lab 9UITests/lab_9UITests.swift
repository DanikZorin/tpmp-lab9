import XCTest

final class lab_9UITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        sleep(2)
    }

    // MARK: - 1. Тест запуска приложения
    func testAppLaunches() throws {
        XCTAssertTrue(app.waitForExistence(timeout: 5))
    }

    // MARK: - 2. Тест наличия кнопки "Войти"
    func testLoginButtonExists() throws {
        let loginButton = app.buttons["Войти"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
    }

    // MARK: - 3. Тест наличия кнопки "Зарегистрироваться"
    func testRegisterButtonExists() throws {
        let registerButton = app.buttons["Зарегистрироваться"]
        XCTAssertTrue(registerButton.waitForExistence(timeout: 5))
    }

    // MARK: - 4. Тест перехода на экран регистрации
    func testNavigateToRegistration() throws {
        app.buttons["Зарегистрироваться"].tap()
        
        let registerTitle = app.staticTexts["Регистрация"]
        XCTAssertTrue(registerTitle.waitForExistence(timeout: 3))
        
        app.navigationBars.buttons.firstMatch.tap()
    }

    // MARK: - 5. Тест возврата с экрана регистрации
    func testBackFromRegistration() throws {
        app.buttons["Зарегистрироваться"].tap()
        
        let registerTitle = app.staticTexts["Регистрация"]
        XCTAssertTrue(registerTitle.waitForExistence(timeout: 3))
        
        app.navigationBars.buttons.firstMatch.tap()
        
        let loginButton = app.buttons["Войти"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 3))
    }
}
