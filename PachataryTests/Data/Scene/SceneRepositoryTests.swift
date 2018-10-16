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

    class ScenarioMaker {
        
        let xcTestCase: XCTestCase!
        let mockApiRepo = MockSceneApiRepo()
        var repo: SceneRepoImplementation<MockSceneResultCache>!
        var caches = [MockSceneResultCache]()
        var resultObservable: Observable<Result<[Scene]>>!
        
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
        
        func when_scenes_observable(_ experienceId: String) -> ScenarioMaker {
            resultObservable = repo.scenesObservable(experienceId: experienceId)
            return self
        }
        
        func wait_for_result(_ sceneResult: Result<[Scene]>, experiendeId: String) -> ScenarioMaker {
            repo.cacheStore[experiendeId]?.waitForResult(sceneResult, xcTestCase: self.xcTestCase)
            return self
        }
        
        func consume_result_observable() -> ScenarioMaker {
            _ = resultObservable.subscribe()
            return self
        }
        
        func then_should_return_observable_with(_ sceneResult: Result<[Scene]>) -> ScenarioMaker {
            do { let results = try resultObservable.take(1).toBlocking().toArray()
                assert(results == [sceneResult])
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_call_api_with(_ experienceIds: [String]) -> ScenarioMaker {
            assert(mockApiRepo.calls == experienceIds)
            return self
        }
        
        @discardableResult
        func then_generate_cache_should_be_called(times: Int) -> ScenarioMaker {
            assert(caches.count == times)
            return self
        }
    }
}

class MockSceneApiRepo: SceneApiRepository {

    var resultScenesForExperienceId = [String:Result<[Scene]>]()
    var calls = [String]()
    
    init() {}
    
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        calls.append(experienceId)
        return Observable.just(resultScenesForExperienceId[experienceId]!)
    }
}

class MockSceneResultCache: ResultCache {
    typealias cacheType = Scene
    
    var replaceResultObserver: AnyObserver<Result<[Scene]>>
    var addOrUpdateObserver: AnyObserver<[Scene]>
    var updateObserver: AnyObserver<[Scene]>
    var emittedReplaceResults = [Result<[Scene]>]()
    let resultSubject = PublishSubject<Result<[Scene]>>()
    var resultObservable: Observable<Result<[Scene]>>

    init() {
        let resultConnectable = resultSubject.asObservable().replay(1)
        resultObservable = resultConnectable
        _ = resultConnectable.connect()
        addOrUpdateObserver = PublishSubject<[Scene]>().asObserver()
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

    func addOrUpdate(_ list: [Scene]) {
        addOrUpdateObserver.onNext(list)
    }

    func update(_ list: [Scene]) {
        updateObserver.onNext(list)
    }

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
