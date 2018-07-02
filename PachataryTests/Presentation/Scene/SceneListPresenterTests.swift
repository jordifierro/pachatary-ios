import XCTest
import RxSwift

@testable import Pachatary

class SceneListPresenterTests: XCTestCase {
    
    func test_on_create_asks_scenes_with_experience_id() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_a_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                              experienceId: "7")
            .when_create_presenter()
            .then_should_call_scenes_repo_observable_with(experienceId: "7")
    }
    
    func test_on_response_success_shows_scenes_with_selected_scene_id() {
        ScenarioMaker()
            .given_an_experience_id_for_presenter("7")
            .given_an_scene_id_for_presenter("9")
            .given_a_scenes_observable_result(Result(.success, data: [Scene("1"), Scene("3")]),
                                              experienceId: "7")
            .when_create_presenter()
            .then_should_call_show_scenes_with([Scene("1"), Scene("3")], andScrollTo: "9")
    }

    class ScenarioMaker {
        let mockSceneRepo = SceneRepoMock()
        var mockView = SceneListViewMock()
        var presenter: SceneListPresenter!
        
        init() {
            presenter = SceneListPresenter(mockSceneRepo, CurrentThreadScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_experience_id_for_presenter(_ experienceId: String) -> ScenarioMaker {
            presenter.experienceId = experienceId
            return self
        }
        
        func given_an_scene_id_for_presenter(_ sceneId: String) -> ScenarioMaker {
            presenter.sceneId = sceneId
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
        func then_should_call_show_scenes_with(_ scenes: [Scene], andScrollTo sceneId: String) -> ScenarioMaker {
            assert(scenes == mockView.showScenesCalls[0].0)
            assert(sceneId == mockView.showScenesCalls[0].1)
            return self
        }
    }
}

class SceneListViewMock: SceneListView {
    
    var showScenesCalls = [([Scene], String?)]()
    var finishCalls = 0
    
    func showScenes(_ scenes: [Scene], showSceneWithId sceneId: String?) {
        showScenesCalls.append((scenes, sceneId))
    }
    
    func finish() {
        finishCalls += 1
    }
}


