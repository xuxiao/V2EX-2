import UIKit

enum ThemeType {
    case normal
    case night
}

struct Theme {
    
    struct Color {
        static let globalColor = #colorLiteral(red: 0.2007454634, green: 0.2006202042, blue: 0.2684206069, alpha: 1) // 全局色
        static let navColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)//#colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1764705882, alpha: 1)
        static let borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        static let bgColor = #colorLiteral(red: 0.9366690335, green: 0.9459429843, blue: 0.9459429843, alpha: 1) // 背景颜色
        static let disableColor = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8431372549, alpha: 1)
        static let grayColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1764705882, alpha: 0.4964415668)
        static let textInkyColor = #colorLiteral(red: 0.4235294118, green: 0.4470588235, blue: 0.4509803922, alpha: 1)
    }
    
    struct Font {
        static let body = UIFont.systemFont(ofSize: 16)
        static let small = UIFont.systemFont(ofSize: 14)
        static let heading1 = UIFont.systemFont(ofSize: 28)
        static let heading2 = UIFont.systemFont(ofSize: 24)
        static let heading3 = UIFont.systemFont(ofSize: 18)
    }
}
