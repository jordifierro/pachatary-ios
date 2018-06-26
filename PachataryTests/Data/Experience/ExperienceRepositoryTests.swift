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
            .then_should_emit_request_through_requester_actions_observer(.getFirsts)
    }
    
    func test_paginate_emit_paginate_request_through_explore_requester() {
        ScenarioMaker()
            .when_paginate()
            .then_should_emit_request_through_requester_actions_observer(.paginate)
    }

    func test_sets_up_requester_to_call_api_explore() {
        ScenarioMaker()
            .given_an_api_that_returns_on_explore([Result(.success, data: [Experience("2")])])
            .when_get_first_callable_from_requester_is_called()
            .then_result_should_be_observable_with([Result(.success, data: [Experience("2")])])
    }
    
    func test_sets_up_requester_to_call_api_paginate() {
        ScenarioMaker()
            .given_an_api_that_returns_on_paginate([Result(.success, data: [Experience("2")])])
            .when_paginate_callable_from_requester_is_called()
            .then_result_should_be_observable_with([Result(.success, data: [Experience("2")])])
    }
    
    class ScenarioMaker {
        
        let mockApiRepo = MockExperienceApiRepo()
        let mockRequester = MockExperienceRequester()
        let repo: ExperienceRepository

        var experiencesObservableResult: Observable<Result<[Experience]>>!
        var callableResult: Observable<Result<[Experience]>>!
        
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
            mockApiRepo.apiGetFirstsCallResultObservable = Observable.from(results)
            return self
        }
        
        func given_an_api_that_returns_on_paginate(_ results: [Result<[Experience]>])
                                                                                  -> ScenarioMaker {
                mockApiRepo.apiPaginateCallResultObservable = Observable.from(results)
                return self
        }
        
        func when_get_first_callable_from_requester_is_called() -> ScenarioMaker {
            callableResult = mockRequester.getFirstsCallable(Request(.getFirsts))
            return self
        }

        func when_paginate_callable_from_requester_is_called() -> ScenarioMaker {
            callableResult = mockRequester.paginateCallable("")
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
        
        func when_paginate() -> ScenarioMaker {
            repo.paginate(kind: .explore)
            return self
        }
        
        @discardableResult
        func then_should_emit_request_through_requester_actions_observer(
            _ action: Request.Action) -> ScenarioMaker {
            assert(mockRequester.actionsObserverCalls == [Request(action)])
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
            do { let real = try callableResult.toBlocking().toArray()
                assert(real == expected)
            } catch { assertionFailure() }
            return self
        }
    }
}

class MockExperienceApiRepo: ExperienceApiRepository {

    var apiGetFirstsCallResultObservable: Observable<Result<[Experience]>>?
    var apiPaginateCallResultObservable: Observable<Result<[Experience]>>?
    
    init() {}
    
    func exploreExperiencesObservable() -> Observable<Result<[Experience]>> {
        return apiGetFirstsCallResultObservable!
    }

    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return apiPaginateCallResultObservable!
    }
}

class MockExperienceRequester: Requester {

    typealias requesterType = Experience
    
    var getFirstsCallable: ((Request) -> Observable<Result<[Experience]>>)!
    var paginateCallable: ((String) -> Observable<Result<[Experience]>>)!
    
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
