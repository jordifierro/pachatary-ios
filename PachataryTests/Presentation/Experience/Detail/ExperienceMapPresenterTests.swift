import XCTest
import RxSwift

@testable import Pachatary

class ExperienceMapPresenterTests: XCTestCase {
    
    func test_on_create_asks_scenes_and_experience_with_experience_id() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_an_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                               experienceId: "7")
            .given_an_experience_observable_result(Result(.success, data: Experience("7")),
                                                   experienceId: "7")
            .when_create_presenter()
            .then_should_call_scenes_repo_observable_with(experienceId: "7")
            .then_should_call_experience_repo_observable_with(experienceId: "7")
    }
    
    func test_on_response_success_shows_scenes() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_an_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                              experienceId: "7")
            .given_an_experience_observable_result(Result(.inProgress), experienceId: "7")
            .when_create_presenter()
            .then_should_call_show_scenes_with([Scene("1"), Scene("3")])
    }
    
    func test_on_response_error_finishes_view() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_an_scenes_observable_result(Result(error: DataError.noInternetConnection),
                                              experienceId: "7")
            .given_an_experience_observable_result(Result(.inProgress), experienceId: "7")
            .when_create_presenter()
            .then_should_call_finish()
    }
    
    func test_on_experience_response_success_shows_experience() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_an_experience_observable_result(Result(.success, data: Experience("7")),
                                                   experienceId: "7")
            .given_an_scenes_observable_result(Result(.inProgress), experienceId: "7")
            .when_create_presenter()
            .then_should_call_show_experience_with(Experience("7"))
    }
    
    func test_on_scene_click_navigates_to_scene_list() {
        ScenarioMaker()
            .when_scene_click_with_id("8")
            .then_should_navigate_to_scene_list_with_id("8")
    }

    class ScenarioMaker {
        let mockSceneRepo = SceneRepoMock()
        let mockExperienceRepo = ExperienceRepoMock()
        var mockView = ExperienceMapViewMock()
        var presenter: ExperienceMapPresenter!

        init() {
            presenter = ExperienceMapPresenter(mockSceneRepo, mockExperienceRepo,
                                               CurrentThreadScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_experience_id_for_presenter(_ experienceId: String) -> ScenarioMaker {
            presenter.experienceId = experienceId
            return self
        }
        
        func given_an_scenes_observable_result(_ result: Result<[Scene]>, experienceId: String) -> ScenarioMaker {
            mockSceneRepo.resultSceneForExperience[experienceId] = result
            return self
        }
        
        func given_an_experience_observable_result(_ result: Result<Experience>,
                                                   experienceId: String) -> ScenarioMaker {
            mockExperienceRepo.returnExperience[experienceId] = result
            return self
        }
        
        func when_create_presenter() -> ScenarioMaker {
            presenter.create()
            return self
        }
        
        func when_scene_click_with_id(_ sceneId: String) -> ScenarioMaker {
            presenter.sceneClick(sceneId)
            return self
        }
        
        @discardableResult
        func then_should_call_scenes_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockSceneRepo.scenesObservableCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_experience_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockExperienceRepo.singleExperienceCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_show_scenes_with(_ scenes: [Scene]) -> ScenarioMaker {
            assert([scenes] == mockView.showScenesCalls)
            return self
        }
        
        @discardableResult
        func then_should_call_show_experience_with(_ experience: Experience) -> ScenarioMaker {
            assert([experience] == mockView.showExperienceCalls)
            return self
        }
        
        @discardableResult
        func then_should_call_finish() -> ScenarioMaker {
            assert(mockView.finishCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_navigate_to_scene_list_with_id(_ sceneId: String) -> ScenarioMaker {
            assert(mockView.navigateToSceneListCalls == [sceneId])
            return self
        }
    }
}

class ExperienceMapViewMock: ExperienceMapView {
    
    var showScenesCalls = [[Scene]]()
    var showExperienceCalls = [Experience]()
    var navigateToSceneListCalls = [String]()
    var finishCalls = 0
    
    func showScenes(_ scenes: [Scene]) {
        showScenesCalls.append(scenes)
    }
    
    func showExperience(_ experience: Experience) {
        showExperienceCalls.append(experience)
    }
    
    func finish() {
        finishCalls += 1
    }
    
    func navigateToSceneList(with sceneId: String) {
        navigateToSceneListCalls.append(sceneId)
    }
}
