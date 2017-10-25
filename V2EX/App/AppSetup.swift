import Foundation
import UIKit
import IQKeyboardManagerSwift


struct AppSetup {

    static func prepare() {
        setupKeyboardManager()
        HUD.configureAppearance()
        setupFPS()
    }
}


// MARK: - didFinishLaunchingWithOptions
extension AppSetup {
    
    /// 键盘自处理
    private static func setupKeyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 70
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
//        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses = [
//            CreateTopicViewController.self
//        ]
        IQKeyboardManager.sharedManager().disabledToolbarClasses = [
            TopicDetailViewController.self
        ]
        IQKeyboardManager.sharedManager().disabledTouchResignedClasses = [
            TopicDetailViewController.self
        ]
    }

    private static func setupFPS() {
        DispatchQueue.main.async {
            let label = FPSLabel(frame: CGRect(x: AppWindow.shared.window.bounds.width - 55 - 8, y: 20, width: 55, height: 20))
            label.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
            AppWindow.shared.window.addSubview(label)
        }
    }
}
