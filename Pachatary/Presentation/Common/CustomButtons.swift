import UIKit

class GreenButton: UIButton {}

class WhiteBorderedButton: UIButton {}

extension UIButton {
    @objc dynamic var borderColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    @objc dynamic var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    @objc dynamic var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
}

func setupButtonsDesign() {
    GreenButton.appearance().backgroundColor = UIColor.themeGreen
    GreenButton.appearance().tintColor = UIColor.white
    GreenButton.appearance().cornerRadius = 23
    GreenButton.appearance().alpha = 1
    GreenButton.appearance().isOpaque = true

    WhiteBorderedButton.appearance().backgroundColor = UIColor.white
    WhiteBorderedButton.appearance().tintColor = UIColor.black
    WhiteBorderedButton.appearance().cornerRadius = 23
    WhiteBorderedButton.appearance().borderWidth = 1
    WhiteBorderedButton.appearance().borderColor = UIColor.black
    WhiteBorderedButton.appearance().alpha = 1
    WhiteBorderedButton.appearance().isOpaque = true
}
