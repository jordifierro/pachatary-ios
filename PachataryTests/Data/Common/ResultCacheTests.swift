import Swift
import XCTest
import RxSwift
import RxBlocking

@testable import Pachatary

class ResultCacheTests: XCTestCase {
    
    func test_replace_observer() {
        ScenarioMaker()
            .given_an_experience(id: "3")
            .given_an_experience(id: "4")
            .given_a_result(status: .success, experiences: [0, 1])
            .given_emitted_result_on_replace_observer(result: 1)
            .given_an_experience(id: "5")
            .given_an_experience(id: "6")
            .given_a_result(status: .success, experiences: [2, 3])
            .when_emit_result_on_replace_observer(result: 2)
            .then_should_emit_result_on_subscribe(result: 2)
    }
    
    func test_add_or_update_observer() {
        ScenarioMaker()
            .given_an_experience(id: "3")
            .given_an_experience(id: "4", title: "first")
            .given_a_result(status: .success, experiences: [0, 1])
            .given_emitted_result_on_add_or_update_observer(result: 1)
            .given_an_experience(id: "4", title: "second")
            .given_an_experience(id: "5")
            .given_a_result(status: .success, experiences: [2, 3])
            .when_emit_result_on_add_or_update_observer(result: 2)
            .given_a_result(status: .success, experiences: [2, 3, 0])
            .then_should_emit_result_on_subscribe(result: 3)
    }

    func test_add_or_update_with_place_at_the_end() {
        ScenarioMaker()
            .given_an_experience(id: "3")
            .given_an_experience(id: "4", title: "first")
            .given_a_result(status: .success, experiences: [0, 1])
            .given_emitted_result_on_add_or_update_observer(result: 1)
            .given_an_experience(id: "4", title: "second")
            .given_an_experience(id: "5")
            .given_a_result(status: .success, experiences: [2, 3])
            .when_emit_result_on_add_or_update_observer(result: 2, placeAtTheEnd: true)
            .given_a_result(status: .success, experiences: [0, 2, 3])
            .then_should_emit_result_on_subscribe(result: 3)
    }

    func test_update_observer() {
        ScenarioMaker()
            .given_an_experience(id: "3")
            .given_an_experience(id: "4", title: "first")
            .given_a_result(status: .success, experiences: [0, 1])
            .given_emitted_result_on_replace_observer(result: 1)
            .given_an_experience(id: "4", title: "second")
            .given_an_experience(id: "5")
            .given_a_result(status: .success, experiences: [2, 3])
            .when_emit_result_on_update_observer(result: 2)
            .given_a_result(status: .success, experiences: [0, 2])
            .then_should_emit_result_on_subscribe(result: 3)
    }
    
    func test_caches_last_result() {
        ScenarioMaker()
            .given_an_experience(id: "3")
            .given_a_result(status: .success, experiences: [0])
            
            .when_emit_result_on_replace_observer(result: 1)
            .then_should_emit_result_on_subscribe(result: 1)
            
            .given_an_experience(id: "4")
            .given_a_result(status: .success, experiences: [1])
            .given_emitted_result_on_replace_observer(result: 2)
            
            .given_an_experience(id: "5")
            .given_a_result(status: .success, experiences: [2])
            
            .when_emit_result_on_replace_observer(result: 3)
            .then_should_emit_result_on_subscribe(result: 3)
    }
    
    class ScenarioMaker {
        
        var experiences = [Experience]()
        var results = [Result<[Experience]>]()
        var cache = ResultCacheImplementation<Experience>()
        
        func given_an_experience(id: String, title: String = "") -> ScenarioMaker {
            let experience = Experience(id: id, title: title, description: "", picture: nil,
                                        isMine: false, isSaved: false,
                                        authorProfile: Profile(username: "", bio: "",
                                                               picture: nil, isMe: false),
                                        savesCount: 0)
            experiences.append(experience)
            return self
        }
        
        func given_a_result(status: Result<[Experience]>.ResultStatus,
                            experiences: [Int]) -> ScenarioMaker {
            var selectedExperiences = [Experience]()
            for index in experiences {
                selectedExperiences.append(self.experiences[index])
            }
            let result = Result<[Experience]>(status, data: selectedExperiences)
            self.results.append(result)
            return self
        }
        
        func given_emitted_result_on_replace_observer(result: Int) -> ScenarioMaker {
            self.cache.replaceResult(self.results[result-1])
            return self
        }
        
        func given_emitted_result_on_add_or_update_observer(result: Int,
                                                            placeAtTheEnd: Bool = false) -> ScenarioMaker {
            self.cache.addOrUpdate(self.results[result-1].data!, placeAtTheEnd: placeAtTheEnd)
            return self
        }
        
        func given_emitted_result_on_update_observer(result: Int) -> ScenarioMaker {
            self.cache.update(self.results[result-1].data!)
            return self
        }
        
        func when_emit_result_on_replace_observer(result: Int) -> ScenarioMaker {
            return given_emitted_result_on_replace_observer(result: result)
        }
        
        func when_emit_result_on_add_or_update_observer(result: Int,
                                                        placeAtTheEnd: Bool = false) -> ScenarioMaker {
            return given_emitted_result_on_add_or_update_observer(result: result,
                                                                  placeAtTheEnd: placeAtTheEnd)
        }
        
        func when_emit_result_on_update_observer(result: Int) -> ScenarioMaker {
            return given_emitted_result_on_update_observer(result: result)
        }
        
        @discardableResult
        func then_should_emit_result_on_subscribe(result: Int) -> ScenarioMaker {
            do { let resultItems = try self.cache.resultObservable.take(1).toBlocking().toArray()
                 assert(resultItems.count == 1)
                 assert(resultItems[0] == self.results[result-1])
            } catch let e { assertionFailure(e.localizedDescription) }
            return self
        }
     }
}

class ResultCacheMock: ResultCache {
    typealias cacheType = IdEq

    var resultPublish = PublishSubject<Result<[IdEq]>>()
    var resultObservable: Observable<Result<[IdEq]>>
    var replaceResultCalls = [Result<[IdEq]>]()
    var addOrUpdateCalls = [([IdEq], Bool)]()
    var updateCalls = [[IdEq]]()

    init() {
        resultObservable = Observable.empty()
        resultObservable = resultPublish.asObservable()
    }

    func replaceResult(_ result: Result<[IdEq]>) {
        replaceResultCalls.append(result)
    }

    func addOrUpdate(_ list: [IdEq], placeAtTheEnd: Bool) {
        addOrUpdateCalls.append((list, placeAtTheEnd))
    }

    func update(_ list: [IdEq]) {
        updateCalls.append(list)
    }
}
