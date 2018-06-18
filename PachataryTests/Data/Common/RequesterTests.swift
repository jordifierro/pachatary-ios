import Swift
import XCTest
import RxSwift

@testable import Pachatary

class RequesterTests: XCTestCase {
    
    func test_not_initialized_result_when_get_firsts_calls_callable() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.success))
            .given_a_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_action(.getFirsts)
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.success, data: [IdEq("2")], nextUrl: nil, action: .getFirsts))
    }

    func test_error_result_when_get_firsts_calls_callable() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(error: DataError.noInternetConnection))
            .given_a_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_action(.getFirsts)
            .then_should_emit_through_cache_replace(
                Result<[IdEq]>(.success, data: [IdEq("2")], nextUrl: nil, action: .getFirsts))
    }
    
    func test_inprogress_result_when_get_firsts_does_nothing() {
        ScenarioMaker()
            .given_a_cache_result_flowable(Result<[IdEq]>(.inProgress))
            .given_a_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_action(.getFirsts)
            .then_should_not_emit_through_cache_replace()
    }
    
    func test_succes_and_initialized_result_when_get_firsts_does_nothing() {
        ScenarioMaker()
            .given_a_cache_result_flowable(
                Result<[IdEq]>(.success, data: nil, nextUrl: nil, action: .getFirsts))
            .given_a_callable_that_returns(Result<[IdEq]>(.success, data: [IdEq("2")]))
            .when_emit_action(.getFirsts)
            .then_should_not_emit_through_cache_replace()
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
        
        func given_a_callable_that_returns(_ result: Result<[IdEq]>) -> ScenarioMaker {
            self.requester.getFirstsCallable = { request in return Observable.just(result) }
            return self
        }
        
        func when_emit_action(_ action: Request.Action) -> ScenarioMaker {
            self.requester.actionsObserver.onNext(Request(action))
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
