import Swift
import XCTest
import RxSwift

@testable import Pachatary

class SceneRepositoryTests: XCTestCase {
    
    func test_scenes_observable_call_api_and_creates_caches() {
        ScenarioMaker().buildScenario()
            .given_an_api_repo_that_returns([Scene("4"), Scene("5")], forExperience: "1")
            .given_an_api_repo_that_returns([Scene("6"), Scene("7")], forExperience: "2")
            .given_an_api_repo_that_returns([Scene("8")], forExperience: "3")
            
            .when_scenes_observable("3")
            .then_generate_cache_should_be_called(times: 1)
            .then_should_return_observable_with([Scene("8")])
            .when_scenes_observable("1")
            .then_generate_cache_should_be_called(times: 2)
            .then_should_return_observable_with([Scene("4"), Scene("5")])
            .when_scenes_observable("2")
            .then_generate_cache_should_be_called(times: 3)
            .then_should_return_observable_with([Scene("6"), Scene("7")])
            .then_should_call_api_with(["3", "1", "2"])

            .given_an_api_repo_that_returns([Scene("99")], forExperience: "3")
            .when_scenes_observable("3")
            .then_should_return_observable_with([Scene("8")])
            .then_should_call_api_with(["3", "1", "2"])
            .then_generate_cache_should_be_called(times: 3)
    }

    class ScenarioMaker {
        
        let mockApiRepo = MockSceneApiRepo()
        var repo: SceneRepository!
        var caches = [MockSceneResultCache]()
        var resultObservable: Observable<Result<[Scene]>>!
        
        init() { }
        
        func buildScenario() -> ScenarioMaker {
            repo = SceneRepoImplementation(apiRepo: mockApiRepo, generateNewCache: { return self.generateCache() })
            return self
        }
        
        private func generateCache() -> MockSceneResultCache {
            let newCache = MockSceneResultCache()
            caches.append(newCache)
            return newCache
        }
        
        func given_an_api_repo_that_returns(_ scenes: [Scene], forExperience experienceId: String) -> ScenarioMaker {
            mockApiRepo.resultScenesForExperienceId[experienceId] = scenes
            return self
        }
        
        func when_scenes_observable(_ experienceId: String) -> ScenarioMaker {
            resultObservable = repo.scenesObservable(experienceId: experienceId)
            return self
        }
        
        func then_should_return_observable_with(_ scenes: [Scene]) -> ScenarioMaker {
            do { let results = try resultObservable.toBlocking().toArray()
                assert(results == [Result(.success, data: scenes)])
            } catch { assertionFailure() }
            return self
        }
        
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

    var resultScenesForExperienceId = [String:[Scene]]()
    var calls = [String]()
    
    init() {}
    
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        calls.append(experienceId)
        return Observable.just(Result(.success, data:
            resultScenesForExperienceId[experienceId]))
    }
}

class MockSceneResultCache: ResultCache {
    typealias cacheType = Scene
    
    var replaceResultObserver: AnyObserver<Result<[Scene]>>
    var addOrUpdateObserver: AnyObserver<[Scene]>
    var updateObserver: AnyObserver<[Scene]>
    var emittedReplaceResults = [Result<[Scene]>]()
    var resultObservable: Observable<Result<[Scene]>> { get {
        return Observable.from(emittedReplaceResults)
        }}
    
    init() {
        addOrUpdateObserver = PublishSubject<[Scene]>().asObserver()
        updateObserver = PublishSubject<[Scene]>().asObserver()
        let replaceResultSubject = PublishSubject<Result<[Scene]>>()
        replaceResultObserver = replaceResultSubject.asObserver()
        _ = replaceResultSubject.asObservable()
            .subscribe { event in
                switch event {
                case .next(let result):
                    self.emittedReplaceResults.append(result)
                case .error(_): assertionFailure()
                case .completed: assertionFailure()
                }
        }
    }
}
