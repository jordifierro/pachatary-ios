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
    
    func test_addorupdate_calls_cache_addorupdate() {
        ScenarioMaker()
            .when_addorupdate([IdEq("8"), IdEq("9")])
            .then_should_call_cache_addorupdate(with: [IdEq("8"), IdEq("9")])
    }

    func test_update_calls_cache_addorupdate() {
        ScenarioMaker()
            .when_update([IdEq("8"), IdEq("9")])
            .then_should_call_cache_update(with: [IdEq("8"), IdEq("9")])
    }

    class ScenarioMaker {
        
        let mockCache = ResultCacheMock()
        var requester: RequesterImplementation<ResultCacheMock>? = nil
        var getFirstsReturn: Observable<Result<[IdEq]>>? = nil
        var getFirstsCalls = [Request.Params?]()
        var paginateReturn: Observable<Result<[IdEq]>>? = nil
        var paginateCalls = [String]()
        
        init() {
            requester = RequesterImplementation<ResultCacheMock>(mockCache,
                 { params in
                    self.getFirstsCalls.append(params)
                    return self.getFirstsReturn! },
                 { url in
                    self.paginateCalls.append(url)
                    return self.paginateReturn! })
        }
        
        func given_a_cache_result_flowable(_ result: Result<[IdEq]>) -> ScenarioMaker {
            self.mockCache.resultPublish.onNext(result)
            return self
        }
        
        func given_a_getfirsts_callable_that_returns(for params: Request.Params?,
                                                     _ result: Result<[IdEq]>) -> ScenarioMaker {
            getFirstsReturn = Observable.just(result)
            return self
        }
        
        func given_a_paginate_callable_that_returns(_ result: Result<[IdEq]>) -> ScenarioMaker {
            paginateReturn = Observable.just(result)
            return self
        }
        
        func when_emit_request(_ request: Request) -> ScenarioMaker {
            self.requester!.request(request)
            return self
        }

        func when_addorupdate(_ list: [IdEq]) -> ScenarioMaker {
            self.requester!.addOrUpdate(list)
            return self
        }

        func when_update(_ list: [IdEq]) -> ScenarioMaker {
            self.requester!.update(list)
            return self
        }
        
        @discardableResult
        func then_should_emit_through_cache_replace(_ result: Result<[IdEq]>) -> ScenarioMaker {
            assert(mockCache.replaceResultCalls == [result])
            return self
        }
        
        @discardableResult
        func then_should_not_emit_through_cache_replace() -> ScenarioMaker {
            assert(mockCache.replaceResultCalls.count == 0)
            return self
        }

        @discardableResult
        func then_should_call_cache_addorupdate(with list: [IdEq]) -> ScenarioMaker {
            assert(mockCache.addOrUpdateCalls == [list])
            return self
        }

        @discardableResult
        func then_should_call_cache_update(with list: [IdEq]) -> ScenarioMaker {
            assert(mockCache.updateCalls == [list])
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

class RequesterMock: Requester {
    typealias requesterType = Experience

    var requestCalls = [Request]()
    var resultObservable: Observable<Result<[Experience]>>!
    var updateCalls = [[Experience]]()
    var addOrUpdateCalls = [[Experience]]()

    func request(_ request: Request) {
        requestCalls.append(request)
    }

    func resultsObservable() -> Observable<Result<[Experience]>> {
        return resultObservable
    }

    func update(_ tList: [Experience]) {
        updateCalls.append(tList)
    }

    func addOrUpdate(_ tList: [Experience]) {
        addOrUpdateCalls.append(tList)
    }
}
