import Swift
import XCTest
import RxSwift

@testable import Pachatary

class RequesterTests: XCTestCase {
    
    func test_get_firsts_calls_callable() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.success))
            .given_a_getfirsts_callable_that_returns(for: Request.Params("a"),
                                                     Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_request(Request(.getFirsts, Request.Params("a")))
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.success, data: [IdEq("2")], nextUrl: nil, action: .getFirsts,
                               params: Request.Params("a")))
    }

    func test_inprogress_result_when_get_firsts_does_nothing() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.inProgress))
            .given_a_getfirsts_callable_that_returns(for: Request.Params(""),
                                                     Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_request(Request(.getFirsts))
            .then_should_not_emit_through_cache_replace()
    }

    func test_inprogress_result_and_different_params_calls_callable() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.inProgress))
            .given_a_getfirsts_callable_that_returns(for: Request.Params("a"),
                                                     Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_request(Request(.getFirsts, Request.Params("a")))
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.success, data: [IdEq("2")], nextUrl: nil, action: .getFirsts,
                               params: Request.Params("a")))
    }

    func test_inprogress_when_paginate_does_nothing() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.inProgress))
            .given_a_paginate_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_request(Request(.paginate))
            .then_should_not_emit_through_cache_replace()
    }
    
    func test_error_getting_firsts_when_paginate_does_nothing() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.error, data: nil, nextUrl: nil, action: .paginate, error: DataError.noInternetConnection))
            .given_a_paginate_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_request(Request(.paginate))
            .then_should_not_emit_through_cache_replace()
    }
    
    func test_success_but_uninitialized_when_paginate_does_nothing() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.success, data: nil, nextUrl: nil,
                                                          action: .none))
            .given_a_paginate_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_request(Request(.paginate))
            .then_should_not_emit_through_cache_replace()
    }
    
    func test_paginate_response_inprogress_returns_with_old_data_and_action_paginate() {
        ScenarioMaker()
            .given_a_cache_result_flowable(
                Result<[IdEq]>(.success, data: [IdEq("9")], nextUrl: "some", action: .paginate))
            .given_a_paginate_callable_that_returns(Result<[IdEq]>(.inProgress))
            .when_emit_request(Request(.paginate))
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.inProgress, data: [IdEq("9")], nextUrl: "some", action: .paginate))
    }
    
    func test_paginate_reponse_error_returns_with_old_data_and_action_paginate() {
        ScenarioMaker()
            .given_a_cache_result_flowable(
                Result<[IdEq]>(.success, data: [IdEq("9")], nextUrl: "some", action: .getFirsts))
            .given_a_paginate_callable_that_returns(
                Result<[IdEq]>( error: DataError.noInternetConnection))
            .when_emit_request(Request(.paginate))
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.error, data: [IdEq("9")], nextUrl: "some", action: .paginate,
                               error: DataError.noInternetConnection))
    }
    
    func test_paginate_response_success_returns_action_paginate_and_joined_experiences() {
        ScenarioMaker()
            .given_a_cache_result_flowable(
                Result<[IdEq]>(.success, data: [IdEq("9"), IdEq("6")],
                               nextUrl: "some", action: .getFirsts))
            .given_a_paginate_callable_that_returns(
                Result<[IdEq]>(.success, data: [IdEq("1"), IdEq("3")], nextUrl: "new"))
            .when_emit_request(Request(.paginate))
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.success, data: [IdEq("9"), IdEq("6"), IdEq("1"), IdEq("3")],
                               nextUrl: "new", action: .paginate))
    }
    
    class ScenarioMaker {
        
        let mockCache = MockResultCache()
        let requester: RequesterImplementation<MockResultCache>!
        
        init() {
            requester = RequesterImplementation<MockResultCache>(mockCache)
        }
        
        func given_a_cache_result_flowable(_ result: Result<[IdEq]>) -> ScenarioMaker {
            self.mockCache.emit_through_result(result)
            return self
        }
        
        func given_a_getfirsts_callable_that_returns(for params: Request.Params?,
                                                     _ result: Result<[IdEq]>) -> ScenarioMaker {
            self.requester.getFirstsCallable = { requestParams in
                                                   if requestParams == params {
                                                       return Observable.just(result)
                                                   }
                                                   assertionFailure()
                                                   return Observable.never()
                                               }
            return self
        }
        
        func given_a_paginate_callable_that_returns(_ result: Result<[IdEq]>) -> ScenarioMaker {
            self.requester.paginateCallable = { request in return Observable.just(result) }
            return self
        }
        
        func when_emit_request(_ request: Request) -> ScenarioMaker {
            self.requester.actionsObserver.onNext(request)
            return self
        }
        
        @discardableResult
        func then_should_emit_through_cache_replace(_ result: Result<[IdEq]>) -> ScenarioMaker {
            assert(mockCache.replaces == [result])
            return self
        }
        
        @discardableResult
        func then_should_not_emit_through_cache_replace() -> ScenarioMaker {
            assert(mockCache.replaces.count == 0)
            return self
        }
    }
}

class IdEq: Identifiable & Equatable {
    
    let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    static func == (lhs: IdEq, rhs: IdEq) -> Bool {
        return lhs.id == rhs.id
    }
}

class MockResultCache: ResultCache {
    typealias cacheType = IdEq
    
    var replaceResultObserver: AnyObserver<Result<[IdEq]>>
    var addOrUpdateObserver: AnyObserver<[IdEq]>
    var updateObserver: AnyObserver<[IdEq]>
    var resultObservable: Observable<Result<[IdEq]>>
    
    var resultObserver: AnyObserver<Result<[IdEq]>>
    var replaces = [Result<[IdEq]>]()
    
    init() {
        let resultSubject = PublishSubject<Result<[IdEq]>>()
        resultObservable = resultSubject.asObservable()
        resultObserver = resultSubject.asObserver()
        
        let replaceSubject = PublishSubject<Result<[IdEq]>>()
        replaceResultObserver = replaceSubject.asObserver()

        updateObserver = PublishSubject<[IdEq]>().asObserver()
        addOrUpdateObserver = PublishSubject<[IdEq]>().asObserver()
        
        _ = replaceSubject.subscribe { event in
            switch event {
            case .next(let result):
                self.replaces.append(result)
            case .error: break
            case .completed: break
            }
        }
    }
    
    func emit_through_result(_ result: Result<[IdEq]>) {
        resultObserver.onNext(result)
    }
}
