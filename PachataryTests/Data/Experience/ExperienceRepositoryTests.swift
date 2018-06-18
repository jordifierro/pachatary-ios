import Swift
import XCTest
import RxSwift

@testable import Pachatary

class ExperienceRepositoryTests: XCTestCase {
    
    func test_experiences_observable_returns_explore_requester_results_observable() {
        ScenarioMaker()
            .given_a_requester_that_returns_results([Result(.success, data: [Experience("2")])])
            .when_call_experiences_observable()
            .then_should_return_flowable_with([Result(.success, data: [Experience("2")])])
    }
    
    func test_get_firsts_emit_getfirsts_requests_through_explore_requester() {
        ScenarioMaker()
            .when_get_firsts()
            .then_should_emit_a_getfirts_request_through_requester_actions_observer()
    }
    
    func test_sets_up_requester_to_call_api_explore() {
        ScenarioMaker()
            .given_an_api_that_returns_on_explore([Result(.success, data: [Experience("2")])])
            .when_get_first_callable_from_requester_is_called()
            .then_result_should_be_observable_with([Result(.success, data: [Experience("2")])])
    }
    
    class ScenarioMaker {
        
        let mockApiRepo = MockExperienceApiRepo()
        let mockRequester = MockExperienceRequester()
        let repo: ExperienceRepository

        var experiencesObservableResult: Observable<Result<[Experience]>>!
        var getFirstCallableResult: Observable<Result<[Experience]>>!
        
        init() {
            repo = ExperienceRepoImplementation(apiRepo: mockApiRepo,
                                                exploreRequester: mockRequester)
        }
        
        func given_a_requester_that_returns_results(_ results: [Result<[Experience]>])
                                                                                  -> ScenarioMaker {
            mockRequester.results = results
            return self
        }
        
        func given_an_api_that_returns_on_explore(_ results: [Result<[Experience]>])
                                                                                  -> ScenarioMaker {
            mockApiRepo.apiCallResultObservable = Observable.from(results)
            return self
        }
        
        func when_get_first_callable_from_requester_is_called() -> ScenarioMaker {
            getFirstCallableResult = mockRequester.getFirstsCallable(Request(.getFirsts))
            return self
        }

        func when_call_experiences_observable() -> ScenarioMaker {
            experiencesObservableResult = repo.experiencesObservable(kind: .explore)
            return self
        }
        
        func when_get_firsts() -> ScenarioMaker {
            repo.getFirsts(kind: .explore)
            return self
        }
        
        @discardableResult
        func then_should_emit_a_getfirts_request_through_requester_actions_observer()
                                                                                  -> ScenarioMaker {
            assert(mockRequester.actionsObserverCalls == [Request(.getFirsts)])
            return self
        }
        
        @discardableResult
        func then_should_return_flowable_with(_ expected: [Result<[Experience]>]) -> ScenarioMaker {
            do { let real = try experiencesObservableResult.toBlocking().toArray()
                assert(real == expected)
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_result_should_be_observable_with(_ expected: [Result<[Experience]>])
                                                                                  -> ScenarioMaker {
            do { let real = try getFirstCallableResult.toBlocking().toArray()
                assert(real == expected)
            } catch { assertionFailure() }
            return self
        }
    }
}

class MockExperienceApiRepo: ExperienceApiRepository {
    
    var apiCallResultObservable: Observable<Result<[Experience]>>?
    
    init() {}
    
    func exploreExperiencesObservable() -> Observable<Result<[Experience]>> {
        return apiCallResultObservable!
    }
}

class MockExperienceRequester: Requester {
    typealias requesterType = Experience
    
    var getFirstsCallable: ((Request) -> Observable<Result<[Experience]>>)!
    
    var actionsObserver: AnyObserver<Request>
    var actionsObserverCalls = [Request]()
    
    var results = [Result<[Experience]>]()
    
    init() {
        let actionsSubject = PublishSubject<Request>()
        actionsObserver = actionsSubject.asObserver()
        _ = actionsSubject.asObservable()
            .subscribe { event in
                switch event {
                case .next(let request):
                    self.actionsObserverCalls.append(request)
                case .error: break
                case .completed: break
            }
        }
    }
    
    func resultsObservable() -> Observable<Result<[Experience]>> {
        return Observable.from(results)
    }
}
