import Swift
import XCTest
import RxSwift

@testable import Pachatary

class SceneRepositoryTests: XCTestCase {
    
    func test_scenes_observable_call_api_and_creates_caches() {
        ScenarioMaker(self).buildScenario()
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("4"), Mock.scene("5")]), forExperience: "1")
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("6"), Mock.scene("7")]), forExperience: "2")
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("8")]), forExperience: "3")
            .when_scenes_observable("3")
            .then_generate_cache_should_be_called(times: 1)
            .then_should_return_observable_with(Result(.success, data: [Mock.scene("8")]))
            .when_scenes_observable("1")
            .then_generate_cache_should_be_called(times: 2)
            .then_should_return_observable_with(Result(.success, data: [Mock.scene("4"), Mock.scene("5")]))
            .when_scenes_observable("2")
            .then_generate_cache_should_be_called(times: 3)
            .then_should_return_observable_with(Result(.success, data: [Mock.scene("6"), Mock.scene("7")]))
            .then_should_call_api_with(["3", "1", "2"])

            .given_an_api_repo_that_returns(Result(.success, data: [Mock.scene("99")]),
                                            forExperience: "3")
            .when_scenes_observable("3")
            .then_should_return_observable_with(Result(.success, data: [Mock.scene("8")]))
            .then_should_call_api_with(["3", "1", "2"])
            .then_generate_cache_should_be_called(times: 3)
    }
    
    func test_when_cached_response_is_error_calls_again_when_scenes_observable() {
        ScenarioMaker(self).buildScenario()
            .given_an_api_repo_that_returns(
                Result(.error, error: DataError.noInternetConnection),
                                            forExperience: "1")
            .when_scenes_observable("1")
            .then_should_return_observable_with(
                Result(.error, error: DataError.noInternetConnection))
            .then_generate_cache_should_be_called(times: 1)
            .then_should_call_api_with(["1"])

            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("4"), Mock.scene("5")]), forExperience: "1")
            .when_scenes_observable("1")
            .consume_result_observable()
            .when_scenes_observable("1")
            .wait_for_result(Result(.success, data: [Mock.scene("4"), Mock.scene("5")]), experiendeId: "1")
            .then_should_return_observable_with(Result(.success, data: [Mock.scene("4"), Mock.scene("5")]))
            .then_generate_cache_should_be_called(times: 1)
            .then_should_call_api_with(["1", "1"])
    }

    func test_refresh_scenes_calls_api_again_and_emits() {
        ScenarioMaker(self).buildScenario()
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("4"), Mock.scene("5")]), forExperience: "1")
            .when_scenes_observable("1")
            .wait_for_result(Result(.success, data: [Mock.scene("4"), Mock.scene("5")]), experiendeId: "1")
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("6"), Mock.scene("7")]), forExperience: "1")
            .when_refresh("1")
            .wait_for_result(Result(.success, data: [Mock.scene("6"), Mock.scene("7")]), experiendeId: "1")
            .when_scenes_observable("1")
            .then_generate_cache_should_be_called(times: 1)
            .then_should_return_observable_with(Result(.success, data: [Mock.scene("6"), Mock.scene("7")]))
    }

    func test_create_scene_returns_api_call() {
        ScenarioMaker(self).buildScenario()
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("6"), Mock.scene("5")]), forExperience: "1")
            .when_scenes_observable("1")
            .given_an_api_repo_that_returns_on_create(Result(.success, data: Mock.scene("4")))
            .when_create_scene("1", "t", "d", 1.2, 2.3)
            .then_should_call_api_create("1", "t", "d", 1.2, 2.3)
            .then_should_return(Result(.success, data: Mock.scene("4")))
    }

    func test_edit_scene_returns_api_call() {
        ScenarioMaker(self).buildScenario()
            .given_an_api_repo_that_returns(
                Result(.success, data: [Mock.scene("6"), Mock.scene("5")]), forExperience: "1")
            .when_scenes_observable("1")
            .given_an_api_repo_that_returns_on_edit(
                Result(.success, data: Mock.scene("4", experienceId: "1")))
            .when_edit_scene("1", "t", "d", 1.2, 2.3)
            .then_should_call_api_edit("1", "t", "d", 1.2, 2.3)
            .then_should_return(Result(.success, data: Mock.scene("4", experienceId: "1")))
    }

    class ScenarioMaker {
        
        let xcTestCase: XCTestCase!
        let mockApiRepo = MockSceneApiRepo()
        var repo: SceneRepoImplementation<MockSceneResultCache>!
        var caches = [MockSceneResultCache]()
        var resultScenesObservable: Observable<Result<[Scene]>>!
        var resultSceneObservable: Observable<Result<Scene>>!
        
        init(_ xcTestCase: XCTestCase) {
            self.xcTestCase = xcTestCase
        }
        
        func buildScenario() -> ScenarioMaker {
            repo = SceneRepoImplementation(apiRepo: mockApiRepo, generateNewCache: { return self.generateCache() })
            return self
        }
        
        private func generateCache() -> MockSceneResultCache {
            let newCache = MockSceneResultCache()
            caches.append(newCache)
            return newCache
        }
        
        func given_an_api_repo_that_returns(_ sceneResult: Result<[Scene]>,
                                            forExperience experienceId: String) -> ScenarioMaker {
            mockApiRepo.resultScenesForExperienceId[experienceId] = sceneResult
            return self
        }

        func given_an_api_repo_that_returns_on_create(_ result: Result<Scene>) -> ScenarioMaker {
            mockApiRepo.createSceneResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_edit(_ result: Result<Scene>) -> ScenarioMaker {
            mockApiRepo.editSceneResult = Observable.just(result)
            return self
        }

        func when_scenes_observable(_ experienceId: String) -> ScenarioMaker {
            resultScenesObservable = repo.scenesObservable(experienceId: experienceId)
            return self
        }

        func when_refresh(_ experienceId: String) -> ScenarioMaker {
            repo.refreshScenes(experienceId: experienceId)
            return self
        }

        func when_create_scene(_ experienceId: String, _ title: String, _ description: String,
                               _ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            resultSceneObservable = repo.createScene(experienceId, title,
                                                     description, latitude, longitude)
            return self
        }

        func when_edit_scene(_ sceneId: String, _ title: String, _ description: String,
                             _ latitude: Double, _ longitude: Double) -> ScenarioMaker {
            resultSceneObservable = repo.editScene(sceneId, title,
                                                   description, latitude, longitude)
            return self
        }

        func wait_for_result(_ sceneResult: Result<[Scene]>, experiendeId: String) -> ScenarioMaker {
            repo.cacheStore[experiendeId]?.waitForResult(sceneResult, xcTestCase: self.xcTestCase)
            return self
        }
        
        func consume_result_observable() -> ScenarioMaker {
            _ = resultScenesObservable.subscribe()
            return self
        }

        @discardableResult
        func then_should_return_observable_with(_ sceneResult: Result<[Scene]>) -> ScenarioMaker {
            do { let results = try resultScenesObservable.take(1).toBlocking().toArray()
                assert(results == [sceneResult])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_return(_ result: Result<Scene>) -> ScenarioMaker {
            do { let results = try resultSceneObservable.take(1).toBlocking().toArray()
                assert(results == [result])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_call_api_with(_ experienceIds: [String]) -> ScenarioMaker {
            assert(mockApiRepo.calls == experienceIds)
            return self
        }

        @discardableResult
        func then_should_call_api_create(_ experienceId: String, _ title: String,
                                         _ description: String, _ latitude: Double,
                                         _ longitude: Double) -> ScenarioMaker {
            assert(mockApiRepo.createSceneCalls.count == 1)
            assert(mockApiRepo.createSceneCalls[0].0 == experienceId)
            assert(mockApiRepo.createSceneCalls[0].1 == title)
            assert(mockApiRepo.createSceneCalls[0].2 == description)
            assert(mockApiRepo.createSceneCalls[0].3 == latitude)
            assert(mockApiRepo.createSceneCalls[0].4 == longitude)
            return self
        }

        @discardableResult
        func then_should_call_api_edit(_ sceneId: String, _ title: String,
                                       _ description: String, _ latitude: Double,
                                       _ longitude: Double) -> ScenarioMaker {
            assert(mockApiRepo.editSceneCalls.count == 1)
            assert(mockApiRepo.editSceneCalls[0].0 == sceneId)
            assert(mockApiRepo.editSceneCalls[0].1 == title)
            assert(mockApiRepo.editSceneCalls[0].2 == description)
            assert(mockApiRepo.editSceneCalls[0].3 == latitude)
            assert(mockApiRepo.editSceneCalls[0].4 == longitude)
            return self
        }

        @discardableResult
        func then_generate_cache_should_be_called(times: Int) -> ScenarioMaker {
            assert(caches.count == times)
            return self
        }
    }
}

class MockSceneResultCache: ResultCache {
    typealias cacheType = Scene
    
    var replaceResultObserver: AnyObserver<Result<[Scene]>>
    var addOrUpdateObserver: AnyObserver<([Scene], Bool)>
    var updateObserver: AnyObserver<[Scene]>
    var emittedReplaceResults = [Result<[Scene]>]()
    let resultSubject = PublishSubject<Result<[Scene]>>()
    var resultObservable: Observable<Result<[Scene]>>

    init() {
        let resultConnectable = resultSubject.asObservable().replay(1)
        resultObservable = resultConnectable
        _ = resultConnectable.connect()
        addOrUpdateObserver = PublishSubject<([Scene], Bool)>().asObserver()
        updateObserver = PublishSubject<[Scene]>().asObserver()
        let replaceResultSubject = PublishSubject<Result<[Scene]>>()
        replaceResultObserver = replaceResultSubject.asObserver()
        _ = replaceResultSubject.asObservable()
            .subscribe { event in
                switch event {
                case .next(let result):
                    self.emittedReplaceResults.append(result)
                    self.resultSubject.onNext(result)
                case .error(_): assertionFailure()
                case .completed: assertionFailure()
                }
        }
    }
    
    func replaceResult(_ result: Result<[Scene]>) {
        replaceResultObserver.onNext(result)
    }

    func addOrUpdate(_ list: [Scene], placeAtTheEnd: Bool) {
        addOrUpdateObserver.onNext((list, placeAtTheEnd))
    }

    func update(_ list: [Scene]) {
        updateObserver.onNext(list)
    }

    func remove(_ allItemsThat: @escaping (Scene) -> (Bool)) {}

    func waitForResult(_ waitedResult: Result<[Scene]>, xcTestCase: XCTestCase) {
        let expectation = XCTestExpectation(description: "wait for result")
        _ = resultObservable.subscribe { event in
                switch event {
                case .next(let result):
                    if result == waitedResult { expectation.fulfill() }
                case .error(_): break
                case .completed: break
                }
        }
        xcTestCase.wait(for: [expectation], timeout: 0.1)
    }
}

class SceneRepoMock: SceneRepository {

    var scenesObservableCalls = [String]()
    var resultSceneForExperience = [String:Result<[Scene]>]()
    var refreshScenesCalls = [String]()
    var createScenceCalls = [(String, String, String, Double, Double)]()
    var createSceneResult: Observable<Result<Scene>>!
    var uploadPictureCalls = [(String, UIImage)]()
    var editSceneCalls = [(String, String, String, Double, Double)]()
    var editSceneResult: Observable<Result<Scene>>!
    var sceneObservableCalls = [(String, String)]()
    var sceneObservableResult: Observable<Result<Scene>>!

    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        scenesObservableCalls.append(experienceId)
        return Observable.just(resultSceneForExperience[experienceId]!)
    }

    func refreshScenes(experienceId: String) {
        refreshScenesCalls.append(experienceId)
    }

    func createScene(_ experienceId: String, _ title: String, _ description: String, _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        createScenceCalls.append((experienceId, title, description, latitude, longitude))
        return createSceneResult
    }

    func uploadPicture(_ sceneId: String, _ image: UIImage) {
        uploadPictureCalls.append((sceneId, image))
    }

    func sceneObservable(experienceId: String, sceneId: String) -> Observable<Result<Scene>> {
        sceneObservableCalls.append((experienceId, sceneId))
        return sceneObservableResult
    }

    func editScene(_ sceneId: String, _ title: String, _ description: String, _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        editSceneCalls.append((sceneId, title, description, latitude, longitude))
        return editSceneResult
    }

}
