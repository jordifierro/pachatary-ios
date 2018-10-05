import Swift
import XCTest
import RxSwift

@testable import Pachatary

class ExperienceRequestersSwitchTests: XCTestCase {

    func kindValues() -> [Kind] { return [.explore, .saved, .persons] }
    func kindString(_ kind: Kind) -> String {
        switch kind {
        case .explore:
            return "explore"
        case .saved:
            return "saved"
        case .persons:
            return "persons"
        }
    }
    func modifyValues() -> [Modification] { return [.update, .addOrUpdate] }

    func test_execute_action_calls_appropiate_requester() {
        for kind in kindValues() {
            ScenarioMaker()
            .when_execute_action(kind, Request(.getFirsts, Request.Params("search")))
            .then_should_call_execute_action_on_requester(kind,
                Request(.getFirsts, Request.Params("search")))
        }
    }

    func test_modify_result_calls_appropiate_requester() {
        for modification in modifyValues() {
            for kind in kindValues() {
                ScenarioMaker()
                    .when_modify_result(kind, modification, [Experience("2")])
                    .then_should_call_modify_result_on_requester(kind, modification,
                                                                 [Experience("2")])
            }
        }
    }

    func test_results_observable_calls_appropiate_requester() {
        for kind in kindValues() {
            ScenarioMaker()
                .given_a_results_observable_that_returns(kind,
                    Result(.success, data: [Experience(kindString(kind))]))
                .when_get_results_observable(kind)
                .then_should_return_observable(
                    Result(.success, data: [Experience(kindString(kind))]))
        }
    }

    func test_experience_observable_when_is_in_explore_requester() {
        ScenarioMaker()
            .given_a_results_observable_that_returns(.explore,
                 Result(.success, data: [Experience("3"), Experience("4")]))
            .given_a_results_observable_that_returns(.saved, Result(.inProgress))
            .given_a_results_observable_that_returns(.persons, Result(.error, error: DataError.notCached))
            .when_get_experiences_observable("4")
            .then_should_return_experience_observable(Result(.success, data: Experience("4")))
    }

    func test_experience_observable_when_is_in_saved_requester() {
        ScenarioMaker()
            .given_a_results_observable_that_returns(.saved,
                                                     Result(.success, data: [Experience("3"), Experience("4")]))
            .given_a_results_observable_that_returns(.explore, Result(.inProgress))
            .given_a_results_observable_that_returns(.persons, Result(.error, error: DataError.notCached))
            .when_get_experiences_observable("4")
            .then_should_return_experience_observable(Result(.success, data: Experience("4")))
    }

    func test_experience_observable_when_is_in_persons_requester() {
        ScenarioMaker()
            .given_a_results_observable_that_returns(.persons,
                                                     Result(.success, data: [Experience("3"), Experience("4")]))
            .given_a_results_observable_that_returns(.explore, Result(.inProgress))
            .given_a_results_observable_that_returns(.saved, Result(.error, error: DataError.notCached))
            .when_get_experiences_observable("4")
            .then_should_return_experience_observable(Result(.success, data: Experience("4")))
    }

    class ScenarioMaker {

        let requestersSwitch: ExperienceRequestersSwitch!
        let exploreRequesterMock = RequesterMock()
        let savedRequesterMock = RequesterMock()
        let personsRequesterMock = RequesterMock()
        var resultsObservable: Observable<Result<[Experience]>>
        var experienceObservable: Observable<Result<Experience>>

        init() {
            requestersSwitch = ExperienceRequestersSwitchImplementation(exploreRequesterMock,
                                                                        savedRequesterMock,
                                                                        personsRequesterMock)
            resultsObservable = Observable.empty()
            experienceObservable = Observable.empty()
        }

        func given_a_results_observable_that_returns(_ kind: Kind,
                                                     _ result: Result<[Experience]>) -> ScenarioMaker {
            switch kind {
            case .explore:
                self.exploreRequesterMock.resultObservable = Observable.just(result)
            case .saved:
                self.savedRequesterMock.resultObservable = Observable.just(result)
            case .persons:
                self.personsRequesterMock.resultObservable = Observable.just(result)
            }
            return self
        }

        func when_execute_action(_ kind: Kind, _ request: Request) -> ScenarioMaker {
            self.requestersSwitch.executeAction(kind, request)
            return self
        }

        func when_modify_result(_ kind: Kind, _ modification: Modification,
                                _ list: [Experience]) -> ScenarioMaker {
            self.requestersSwitch.modifyResult(kind, modification, list: list, result: nil)
            return self
        }

        func when_get_results_observable(_ kind: Kind) -> ScenarioMaker {
            resultsObservable = self.requestersSwitch.experiencesObservable(kind)
            return self
        }

        func when_get_experiences_observable(_ experienceId: String) -> ScenarioMaker {
            experienceObservable = self.requestersSwitch.experienceObservable(experienceId)
            return self
        }

        @discardableResult
        func then_should_call_execute_action_on_requester(_ kind: Kind,
                                                          _ request: Request) -> ScenarioMaker {
            switch kind {
            case .explore:
                assert(exploreRequesterMock.requestCalls == [request])
            case .saved:
                assert(savedRequesterMock.requestCalls == [request])
            case .persons:
                assert(personsRequesterMock.requestCalls == [request])
            }
            return self
        }

        @discardableResult
        func then_should_call_modify_result_on_requester(_ kind: Kind, _ modification: Modification,
                                                         _ list: [Experience]) -> ScenarioMaker {
            switch modification {
            case .update:
                switch kind {
                case .explore:
                    assert(exploreRequesterMock.updateCalls == [list])
                case .saved:
                    assert(savedRequesterMock.updateCalls == [list])
                case .persons:
                    assert(personsRequesterMock.updateCalls == [list])
                }
            case .addOrUpdate:
                switch kind {
                case .explore:
                    assert(exploreRequesterMock.addOrUpdateCalls == [list])
                case .saved:
                    assert(savedRequesterMock.addOrUpdateCalls == [list])
                case .persons:
                    assert(personsRequesterMock.addOrUpdateCalls == [list])
                }
            }
            return self
        }

        @discardableResult
        func then_should_return_observable(_ expectedResult: Result<[Experience]>) -> ScenarioMaker {
            do { let result = try resultsObservable.toBlocking().toArray()
                assert(result.count == 1)
                assert(expectedResult == result[0])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_return_experience_observable(_ expectedResult: Result<Experience>) -> ScenarioMaker {
            do { let result = try experienceObservable.toBlocking().toArray()
                assert(result.count == 1)
                assert(expectedResult == result[0])
            } catch { assertionFailure() }
            return self
        }
    }
}

class ExperienceRequestersSwitchMock: ExperienceRequestersSwitch {

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
