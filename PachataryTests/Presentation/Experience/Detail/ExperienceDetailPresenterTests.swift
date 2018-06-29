import XCTest
import RxSwift

@testable import Pachatary

class ExperienceDetailPresenterTests: XCTestCase {
    
    func test_on_create_asks_scenes_with_experience_id() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_a_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                              experienceId: "7")
            .when_create_presenter()
            .then_should_call_scenes_repo_observable_with(experienceId: "7")
    }
    
    func test_on_response_success_shows_scenes() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_a_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                              experienceId: "7")
            .when_create_presenter()
            .then_should_call_show_scenes_with([Scene("1"), Scene("3")])
    }
    
    func test_on_response_error_finishes_view() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_a_scenes_observable_result(Result(error: DataError.noInternetConnection),
                                              experienceId: "7")
            .when_create_presenter()
            .then_should_call_finish()
    }

    class ScenarioMaker {
        let mockSceneRepo = SceneRepoMock()
        var mockView = ExperienceDetailViewMock()
        var presenter: ExperienceDetailPresenter!

        init() {
            presenter = ExperienceDetailPresenter(mockSceneRepo, CurrentThreadScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_experience_id_for_presenter(_ experienceId: String) -> ScenarioMaker {
            presenter.experienceId = experienceId
            return self
        }
        
        func given_a_scenes_observable_result(_ result: Result<[Scene]>, experienceId: String) -> ScenarioMaker {
            mockSceneRepo.resultSceneForExperience[experienceId] = result
            return self
        }
        
        func when_create_presenter() -> ScenarioMaker {
            presenter.create()
            return self
        }
        
        @discardableResult
        func then_should_call_scenes_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockSceneRepo.scenesObservableCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_show_scenes_with(_ scenes: [Scene]) -> ScenarioMaker {
            assert([scenes] == mockView.showScenesCalls)
            return self
        }
        
        @discardableResult
        func then_should_call_finish() -> ScenarioMaker {
            assert(mockView.finishCalls == 1)
            return self
        }
    }
}

class SceneRepoMock: SceneRepository {
    
    var scenesObservableCalls = [String]()
    var resultSceneForExperience = [String:Result<[Scene]>]()
    
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        scenesObservableCalls.append(experienceId)
        return Observable.just(resultSceneForExperience[experienceId]!)
    }
}

class ExperienceDetailViewMock: ExperienceDetailView {
    
    var showScenesCalls = [[Scene]]()
    var finishCalls = 0
    
    func showScenes(_ scenes: [Scene]) {
        showScenesCalls.append(scenes)
    }
    
    func finish() {
        finishCalls += 1
    }
}
