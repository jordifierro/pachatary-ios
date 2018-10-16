import Swift

struct Scene: Equatable, Identifiable {
    
    let id: String
    let title: String
    let description: String
    let picture: BigPicture?
    let latitude: Double
    let longitude: Double
    let experienceId: String

    init(id: String, title: String, description: String, picture: BigPicture?,
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
