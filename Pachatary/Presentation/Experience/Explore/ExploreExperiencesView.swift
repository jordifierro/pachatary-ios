protocol ExploreExperiencesView {
    
    func show(experiences: [Experience])
    func showLoader(_ visibility: Bool)
    func showPaginationLoader(_ visibility: Bool)
    func showError(_ visibility: Bool)
    func showRetry(_ visibility: Bool)
}

