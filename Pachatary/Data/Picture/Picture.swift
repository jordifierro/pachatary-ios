import Swift

struct Picture: Equatable {
    
    let smallUrl: String
    let mediumUrl: String
    let largeUrl: String
    
    init(smallUrl: String, mediumUrl: String, largeUrl: String) {
        self.smallUrl = smallUrl
        self.mediumUrl = mediumUrl
        self.largeUrl = largeUrl
    }
    
    static func == (lhs: Picture, rhs: Picture) -> Bool {
        return lhs.smallUrl == rhs.smallUrl &&
            lhs.mediumUrl == rhs.mediumUrl &&
            lhs.largeUrl == rhs.largeUrl
    }
}
