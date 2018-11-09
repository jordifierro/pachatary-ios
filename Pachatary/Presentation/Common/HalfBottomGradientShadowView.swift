import UIKit

class HalfBottomGradientShadowView: UIView {

    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        gradientLayer.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                 UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor]
        gradientLayer.locations = [0.5, 1]
    }
}
