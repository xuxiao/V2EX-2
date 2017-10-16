import Foundation
import UIKit
import IQKeyboardManagerSwift


struct AppSetup {

    static func setup() {
        setupWindow()
        setupKeyboardManager()

        HUD.configureAppearance()
    }
}


// MARK: - didFinishLaunchingWithOptions
extension AppSetup {

    /// 设置根窗口
    private static func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.setCornerRadius = 5
        window.makeKeyAndVisible()
        AppDelegate.shared.window = window

        window.rootViewController = TabBarViewController()
//        window.rootViewController = LoginViewController()
    }
    
    /// 键盘自处理
    private static func setupKeyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 70
//        IQKeyboardManager.sharedManager().disabledToolbarClasses = [
//        ]
//        IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.append(AutoPreviousNextView.self)
    }
}
