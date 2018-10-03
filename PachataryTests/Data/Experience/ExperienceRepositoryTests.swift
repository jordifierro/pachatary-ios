import Swift
import XCTest
import RxSwift

@testable import Pachatary

class ExperienceRepositoryTests: XCTestCase {
    
    func kindValues() -> [Kind] { return [.explore, .saved] }
    
    func test_explore_experiences_observable_returns_from_switch_explore() {
        ScenarioMaker()
            .given_a_switch_that_returns_experiences_observable(.explore,
                Result(.success, data: [Experience("3")]))
            .when_experiences_observable(.explore)
            .then_should_return_experiences_observable(Result(.success, data: [Experience("3")]))
    }
    
    func test_saved_experiences_observable_returns_from_switch_saved_and_filters_saved() {
        ScenarioMaker()
            .given_a_switch_that_returns_experiences_observable(.saved,
                Result(.success, data: [Experience("3", isSaved: false),
                                        Experience("4", isSaved: true)]))
            .when_experiences_observable(.saved)
            .then_should_return_experiences_observable(
                Result(.success, data: [Experience("4", isSaved: true)]))
    }

    func test_experience_observable_returns_from_switch() {
        ScenarioMaker()
            .given_a_switch_that_returns_experience_observable("8",
                Result(.success, data: Experience("8")))
            .when_experience_observable("8")
            .then_should_return_experience_observable(Result(.success, data: Experience("8")))
    }
    
    func test_getfirsts_executes_action() {
        for kind in kindValues() {
            ScenarioMaker()
                .when_getfirts(kind, Request.Params("test"))
                .then_should_call_execute_action(kind, Request(.getFirsts, Request.Params("test")))
        }
    }

    func test_paginate_executes_action() {
        for kind in kindValues() {
            ScenarioMaker()
                .when_paginate(kind)
                .then_should_call_execute_action(kind, Request(.paginate))
        }
    }

    func test_save_experience() {
        ScenarioMaker()
            .given_a_switch_that_returns_experience_observable("4", Result(.success, data: Experience("4", isSaved: false, savesCount: 8)))
            .when_save_experience("4")
            .then_should_call_api_save("4")
            .then_should_modify_switch_result(0, .explore, .update, [Experience("4", isSaved: true, savesCount: 9)])
            .then_should_modify_switch_result(1, .saved, .addOrUpdate, [Experience("4", isSaved: true, savesCount: 9)])
    }
    
    func test_unsave_experience() {
        ScenarioMaker()
            .given_a_switch_that_returns_experience_observable("4", Result(.success, data: Experience("4", isSaved: true, savesCount: 8)))
            .when_unsave_experience("4")
            .then_should_call_api_unsave("4")
            .then_should_modify_switch_result(0, .explore, .update, [Experience("4", isSaved: false, savesCount: 7)])
            .then_should_modify_switch_result(1, .saved, .addOrUpdate, [Experience("4", isSaved: false, savesCount: 7)])
    }

    class ScenarioMaker {
        
        let mockApiRepo = MockExperienceApiRepo()
        let mockRequestersSwitch = MockExperienceRequestersSwitch()
        let repo: ExperienceRepository

        var experiencesObservableResult: Observable<Result<[Experience]>>!
        var experienceObservableResult: Observable<Result<Experience>>!

        init() {
            repo = ExperienceRepoImplementation(apiRepo: mockApiRepo,
                                                requestersSwitch: mockRequestersSwitch)
        }
        
        func given_a_switch_that_returns_experience_observable(_ experienceId: String,
                                               _ result: Result<Experience>) -> ScenarioMaker {
            mockRequestersSwitch.experienceObservableResult[experienceId] = Observable.just(result)
            return self
        }
        
        func given_a_switch_that_returns_experiences_observable(_ kind: Kind,
                                                                _ result: Result<[Experience]>) -> ScenarioMaker{
            mockRequestersSwitch.experiencesObservableResult[kind] = Observable.just(result)
            return self
        }
        
        func when_getfirts(_ kind: Kind, _ params: Request.Params) -> ScenarioMaker {
            self.repo.getFirsts(kind: kind, params: params)
            return self
        }

        func when_paginate(_ kind: Kind) -> ScenarioMaker {
            self.repo.paginate(kind: kind)
            return self
        }

        func when_experience_observable(_ experienceId: String) -> ScenarioMaker {
            experienceObservableResult = self.repo.experienceObservable(experienceId)
            return self
        }
        
        func when_experiences_observable(_ kind: Kind) -> ScenarioMaker {
            experiencesObservableResult = self.repo.experiencesObservable(kind: kind)
            return self
        }
        
        func when_save_experience(_ experienceId: String) -> ScenarioMaker {
            self.repo.saveExperience(experienceId, save: true)
            return self
        }
        
        func when_unsave_experience(_ experienceId: String) -> ScenarioMaker {
            self.repo.saveExperience(experienceId, save: false)
            return self
        }
        
        func then_should_call_api_save(_ experienceId: String) -> ScenarioMaker {
            assert(mockApiRepo.saveCalls.count == 1)
            assert(mockApiRepo.saveCalls[0].0 == experienceId)
            assert(mockApiRepo.saveCalls[0].1 == true)
            return self
        }
        
        func then_should_call_api_unsave(_ experienceId: String) -> ScenarioMaker {
            assert(mockApiRepo.saveCalls.count == 1)
            assert(mockApiRepo.saveCalls[0].0 == experienceId)
            assert(mockApiRepo.saveCalls[0].1 == false)
            return self
        }
        
        @discardableResult
        func then_should_call_execute_action(_ kind: Kind, _ request: Request) -> ScenarioMaker {
            assert(mockRequestersSwitch.executeActionCalls.count == 1)
            assert(mockRequestersSwitch.executeActionCalls[0].0 == kind)
            assert(mockRequestersSwitch.executeActionCalls[0].1 == request)
            return self
        }
        
        @discardableResult
        func then_should_return_experience_observable(_ expectedResult: Result<Experience>) -> ScenarioMaker {
            do { let result = try experienceObservableResult.toBlocking().toArray()
                assert(result.count == 1)
                assert(expectedResult == result[0])
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_return_experiences_observable(_ expectedResult: Result<[Experience]>) -> ScenarioMaker {
            do { let result = try experiencesObservableResult.toBlocking().toArray()
                assert(result.count == 1)
                assert(expectedResult == result[0])
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_modify_switch_result(_ index: Int, _ kind: Kind,
                                              _ modification: Modification,
                                              _ list: [Experience]) -> ScenarioMaker {
            assert(mockRequestersSwitch.modifyResultCalls[index].0 == kind)
            assert(mockRequestersSwitch.modifyResultCalls[index].1 == modification)
            assert(mockRequestersSwitch.modifyResultCalls[index].2 == list)
            assert(mockRequestersSwitch.modifyResultCalls[index].3 == nil)
            return self
        }
    }
}

class MockExperienceApiRepo: ExperienceApiRepository {

    var apiExploreCallResultObservable: Observable<Result<[Experience]>>?
    var apiSavedCallResultObservable: Observable<Result<[Experience]>>?
    var apiPaginateCallResultObservable: Observable<Result<[Experience]>>?
    var saveCalls = [(String, Bool)]()

    init() {}
    
    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?,
                                      _ longitude: Double?) -> Observable<Result<[Experience]>> {
        return apiExploreCallResultObservable!
    }

    func savedExperiencesObservable() -> Observable<Result<[Experience]>> {
        return apiSavedCallResultObservable!
    }

    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return apiPaginateCallResultObservable!
    }
    
    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>> {
        saveCalls.append((experienceId, save))
        return Observable.just(Result(.success, data: true))
    }
}

class MockExperienceRequestersSwitch: ExperienceRequestersSwitch {
    
    var executeActionCalls = [(Kind, Request)]()
    var modifyResultCalls = [(Kind, Modification, [Experience]?, Result<[Experience]>?)]()
    var experiencesObservableResult = [Kind:Observable<Result<[Experience]>>]()
    var experienceObservableResult = [String:Observable<Result<Experience>>]()
    
    func executeAction(_ kind: Kind, _ request: Request) {
        executeActionCalls.append((kind, request))
    }
    
    func modifyResult(_ kind: Kind, _ modification: Modification, list: [Experience]?, result: Result<[Experience]>?) {
        modifyResultCalls.append((kind, modification, list, result))
    }
    
    func experiencesObservable(_ kind: Kind) -> Observable<Result<[Experience]>> {
        return experiencesObservableResult[kind]!
    }
    
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return experienceObservableResult[experienceId]!
    }
}
