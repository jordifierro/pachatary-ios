import XCTest
import RxSwift
@testable import Pachatary

class ExploreExperiencesPresenterTests: XCTestCase {
    
    func test_on_create_asks_experiences_to_repo_and_shows_on_view() {
        ScenarioMaker().buildScenario()
            .given_an_experience(id: "7")
            .given_an_experience(id: "8")
            .given_an_experience_repo_that_returns_that_experiences()
            .when_create_presenter()
            .then_show_should_be_called_with_experiences_on_view()
    }
    
    class ScenarioMaker {
        var experiences: [Experience] = []
        let mockRepo = ExperienceRepoMock()
        let mockView = ExploreExperiencesViewMock()
        var presenter: ExploreExperiencesPresenter!
        
        func buildScenario() -> ScenarioMaker {
            presenter = ExploreExperiencesPresenter(mockRepo, MainScheduler.instance)
            presenter.view = mockView
            return self
        }
        
        func given_an_experience(id: String, title: String = "", description: String = "",
                                 picture: Picture? = nil, isMine: Bool = false,
                                 isSaved: Bool = false, authorUsername: String = "",
                                 savesCount: Int = 0) -> ScenarioMaker {
            experiences.append(Experience(id: id, title: title, description: description,
                                          picture: picture, isMine: isMine, isSaved: isSaved,
                                          authorUsername: authorUsername, savesCount: savesCount))
            return self
        }
        
        func given_an_experience_repo_that_returns_that_experiences() -> ScenarioMaker {
            mockRepo.returnExperiences = experiences
            return self
        }
        
        func when_create_presenter() -> ScenarioMaker {
            presenter.create()
            return self
        }
        
        @discardableResult
        func then_show_should_be_called_with_experiences_on_view() -> ScenarioMaker {
            assert(experiences == mockView.showCalls[0])
            return self
        }
    }
}

class ExploreExperiencesViewMock: ExploreExperiencesView {
    
    var showCalls: [[Experience]] = []
    
    func show(experiences: [Experience]) {
        self.showCalls.append(experiences)
    }
}

class ExperienceRepoMock: ExperienceRepository {
    
    var returnExperiences: [Experience]!
    
    func experiencesObservable() -> Observable<[Experience]> {
        return Observable.just(returnExperiences)
    }
}
