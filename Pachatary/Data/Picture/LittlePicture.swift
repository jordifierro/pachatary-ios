import Swift

struct LittlePicture: Equatable {
    
    let tinyUrl: String
    let smallUrl: String
    let mediumUrl: String

    init(tinyUrl: String, smallUrl: String, mediumUrl: String) {
        self.tinyUrl = tinyUrl
        self.smallUrl = smallUrl
        self.mediumUrl = mediumUrl
    }
    
    static func == (lhs: LittlePicture, rhs: LittlePicture) -> Bool {
        return lhs.tinyUrl == rhs.tinyUrl &&
            lhs.smallUrl == rhs.smallUrl &&
            lhs.mediumUrl == rhs.mediumUrl
    }
}
