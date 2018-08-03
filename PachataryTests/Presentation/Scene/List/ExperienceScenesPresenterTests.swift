import XCTest
import RxSwift

@testable import Pachatary

class ExperienceScenesPresenterTests: XCTestCase {
    
    func test_on_create_asks_scenes_and_experience_with_experience_id() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_an_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                              experienceId: "7")
            .given_an_experience_observable_result(Result(.success, data: Experience("9")),
                                                   experienceId: "7")
            .when_create_presenter()
            .then_should_call_scene_repo_observable_with(experienceId: "7")
            .then_should_call_experience_repo_observable_with(experienceId: "7")
            .then_should_call_show_scenes_with([Scene("1"), Scene("3")],
                                               experience: Experience("9"))
    }
    
    func test_on_go_to_map_click_navigates_to_map() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("4")
            .when_go_to_map_click()
            .then_should_navigate_to_map()
    }
    
    func test_on_locate_scene_click_navigates_to_map_with_scene_id() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("4")
            .when_locate_scene_click("7")
            .then_should_navigate_to_map(sceneId: "7")
    }
    
    class ScenarioMaker {
        let mockSceneRepo = SceneRepoMock()
        let mockExperienceRepo = ExperienceRepoMock()
        var mockView = ExperienceScenesViewMock()
        var presenter: ExperienceScenesPresenter!
        
        init() {
            presenter = ExperienceScenesPresenter(mockSceneRepo, mockExperienceRepo,
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
        
        func when_go_to_map_click() -> ScenarioMaker {
            presenter.onGoToMapClick()
            return self
        }
        
        func when_locate_scene_click(_ sceneId: String) -> ScenarioMaker {
            presenter.onLocateSceneClick(sceneId)
            return self
        }
        
        @discardableResult
        func then_should_call_scene_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockSceneRepo.scenesObservableCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_experience_repo_observable_with(experienceId: String) -> ScenarioMaker {
            assert(mockExperienceRepo.singleExperienceCalls == [experienceId])
            return self
        }
        
        @discardableResult
        func then_should_call_show_scenes_with(_ scenes: [Scene], experience: Experience)
                                                                                  -> ScenarioMaker {
            assert(scenes == mockView.showScenesCalls[0].0)
            assert(experience == mockView.showScenesCalls[0].1)
            return self
        }
        
        @discardableResult
        func then_should_navigate_to_map(sceneId: String? = nil) -> ScenarioMaker {
            assert(mockView.navigateToMapCalls == [sceneId])
            return self
        }
    }
}

class ExperienceScenesViewMock: ExperienceScenesView {

    var showScenesCalls = [([Scene], Experience)]()
    var navigateToMapCalls = [String?]()
    var finishCalls = 0

    func showScenes(_ scenes: [Scene], experience: Experience) {
        showScenesCalls.append((scenes, experience))
    }
    
    func navigateToMap(_ sceneId: String?) {
        navigateToMapCalls.append(sceneId)
    }
    
    func finish() {
        finishCalls += 1
    }
}
