import UIKit

class PictureDeviceCompat {

    class LittlePictureCompat {
        let iconSizeUrl: String
        let halfScreenSizeUrl: String

        init(_ iconSizeUrl: String, _ halfScreenSizeUrl: String) {
            self.iconSizeUrl = iconSizeUrl
            self.halfScreenSizeUrl = halfScreenSizeUrl
        }
    }

    class BigPictureCompat {
        let halfScreenSizeUrl: String
        let fullScreenSizeUrl: String

        init(_ halfScreenSizeUrl: String, _ fullScreenSizeUrl: String) {
            self.halfScreenSizeUrl = halfScreenSizeUrl
            self.fullScreenSizeUrl = fullScreenSizeUrl
        }
    }

    static func convert(_ littlePicture: LittlePicture) -> LittlePictureCompat {
        if UIScreen.main.bounds.width < 1280 {
            return LittlePictureCompat(littlePicture.tinyUrl, littlePicture.smallUrl)
        }
        else { return LittlePictureCompat(littlePicture.smallUrl, littlePicture.mediumUrl) }
    }

    static func convert(_ bigPicture: BigPicture) -> BigPictureCompat {
        if UIScreen.main.bounds.width < 1280 {
            return BigPictureCompat(bigPicture.smallUrl, bigPicture.mediumUrl)
        }
        else { return BigPictureCompat(bigPicture.mediumUrl, bigPicture.largeUrl) }
    }
}
