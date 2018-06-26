import Swift

struct Scene: Equatable, Identifiable {
    
    let id: String
    let title: String
    let description: String
    let picture: Picture?
    let latitude: Double
    let longitude: Double
    let experienceId: String

    init(_ id: String) {
        self.id = id
        self.title = ""
        self.description = ""
        self.picture = nil
        self.latitude = 0.0
        self.longitude = 0.0
        self.experienceId = ""
    }
    
    init(id: String, title: String, description: String, picture: Picture?,
         latitude: Double, longitude: Double, experienceId: String) {
        self.id = id
        self.title = title
        self.description = description
        self.picture = picture
        self.latitude = latitude
        self.longitude = longitude
        self.experienceId = experienceId
    }
    
    static func == (lhs: Scene, rhs: Scene) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.picture == rhs.picture &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.experienceId == rhs.experienceId
    }
}
