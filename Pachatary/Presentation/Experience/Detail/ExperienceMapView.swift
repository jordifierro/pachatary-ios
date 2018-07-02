import Swift

protocol ExperienceMapView {
    func showScenes(_ scenes: [Scene])
    func navigateToSceneList(with sceneId: String)
    func finish()
}

