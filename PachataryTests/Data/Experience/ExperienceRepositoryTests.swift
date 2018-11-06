import Swift
import XCTest
import RxSwift

@testable import Pachatary

class ExperienceRepositoryTests: XCTestCase {
    
    func kindValues() -> [Kind] { return [.explore, .saved, .persons] }
    
    func test_explore_and_persons_experiences_observable_returns_from_switch_explore() {
        for kind in [Kind.explore, Kind.persons] {
            ScenarioMaker()
                .given_a_switch_that_returns_experiences_observable(kind,
                    Result(.success, data: [Mock.experience("3")]))
                .when_experiences_observable(kind)
                .then_should_return_experiences_observable(Result(.success, data: [Mock.experience("3")]))
        }
    }
    
    func test_saved_experiences_observable_returns_from_switch_saved_and_filters_saved() {
        ScenarioMaker()
            .given_a_switch_that_returns_experiences_observable(.saved,
                Result(.success, data: [Mock.experience("3", isSaved: false),
                                        Mock.experience("4", isSaved: true)]))
            .when_experiences_observable(.saved)
            .then_should_return_experiences_observable(
                Result(.success, data: [Mock.experience("4", isSaved: true)]))
    }

    func test_experience_observable_returns_from_switch() {
        ScenarioMaker()
            .given_a_switch_that_returns_experience_observable("8",
                Result(.success, data: Mock.experience("8")))
            .when_experience_observable("8")
            .then_should_return_experience_observable(Result(.success, data: Mock.experience("8")))
    }

    func test_experience_observable_when_not_cached_returns_from_api_and_caches_on_other() {
        ScenarioMaker()
            .given_a_switch_that_returns_experience_observable("8",
                                                               Result(.error, error: DataError.notCached))
            .given_an_api_repo_that_returns_on_experience(Result(.success, data: Mock.experience("9")))
            .when_experience_observable("8")
            .then_should_return_experience_observable(Result(.success, data: Mock.experience("9")))
            .then_should_modify_switch_result(0, .other, .addOrUpdate, [Mock.experience("9")])
    }

    
    func test_getfirsts_executes_action() {
        for kind in kindValues() {
            ScenarioMaker()
                .when_getfirsts(kind, Request.Params("test"))
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
            .given_a_switch_that_returns_experience_observable("4", Result(.success, data: Mock.experience("4", isSaved: false, savesCount: 8)))
            .given_an_api_repo_that_returns_on_save(Result(.success, data: true))
            .when_save_experience("4")
            .then_should_call_api_save("4")
            .then_should_modify_switch_result(0, .explore, .update, [Mock.experience("4", isSaved: true, savesCount: 9)])
            .then_should_modify_switch_result(1, .persons, .update, [Mock.experience("4", isSaved: true, savesCount: 9)])
            .then_should_modify_switch_result(2, .other, .update, [Mock.experience("4", isSaved: true, savesCount: 9)])
            .then_should_modify_switch_result(3, .saved, .addOrUpdate, [Mock.experience("4", isSaved: true, savesCount: 9)])
    }
    
    func test_unsave_experience() {
        ScenarioMaker()
            .given_a_switch_that_returns_experience_observable("4", Result(.success, data: Mock.experience("4", isSaved: true, savesCount: 8)))
            .given_an_api_repo_that_returns_on_save(Result(.success, data: true))
            .when_unsave_experience("4")
            .then_should_call_api_unsave("4")
            .then_should_modify_switch_result(0, .explore, .update, [Mock.experience("4", isSaved: false, savesCount: 7)])
            .then_should_modify_switch_result(1, .persons, .update, [Mock.experience("4", isSaved: false, savesCount: 7)])
            .then_should_modify_switch_result(2, .other, .update, [Mock.experience("4", isSaved: false, savesCount: 7)])
            .then_should_modify_switch_result(3, .saved, .addOrUpdate, [Mock.experience("4", isSaved: false, savesCount: 7)])
    }

    func test_translate_share_id() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_translate(Result(.success, data: "id"))
            .when_translate_share_id("share")
            .then_should_call_api_translate_share_id("share")
            .then_should_return_string_observable(Result(.success, data: "id"))
    }

    func test_share_url() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_share_url(Result(.success, data: "exp_url"))
            .when_share_url("5")
            .then_should_call_api_share_url("5")
            .then_should_return_string_observable(Result(.success, data: "exp_url"))
    }

    func test_refresh_experience() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_experience(Result(.success, data: Mock.experience("4")))
            .when_refresh_experience("4")
            .then_should_call_api_experience("4")
            .then_should_modify_switch_result(0, .explore, .update, [Mock.experience("4")])
            .then_should_modify_switch_result(1, .persons, .update, [Mock.experience("4")])
            .then_should_modify_switch_result(2, .other, .update, [Mock.experience("4")])
            .then_should_modify_switch_result(3, .saved, .update, [Mock.experience("4")])
    }

    func test_create_experience() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_create(Result(.success, data: Mock.experience("4")))
            .when_create_experience("t", "d")
            .then_should_call_api_create("t", "d")
            .then_should_return_experience_observable(Result(.success, data: Mock.experience("4")))
            .then_should_modify_switch_result(0, .mine, .addOrUpdate, [Mock.experience("4")])
    }

    func test_upload_picture() {
        let pic = UIImage()
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_upload_picture(Result(.success, data: Mock.experience("4")))
            .when_upload_picture("4", pic)
            .then_should_call_api_upload_picture("4", pic)
            .then_should_modify_switch_result(0, .mine, .update, [Mock.experience("4")])
            .then_should_modify_switch_result(1, .explore, .update, [Mock.experience("4")])
            .then_should_modify_switch_result(2, .persons, .update, [Mock.experience("4")])
    }

    func test_edit_experience() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_edit(Result(.success, data: Mock.experience("4")))
            .when_edit_experience("4", "t", "d")
            .then_should_call_api_edit("4", "t", "d")
            .then_should_return_experience_observable(Result(.success, data: Mock.experience("4")))
            .then_should_modify_switch_result(0, .mine, .update, [Mock.experience("4")])
            .then_should_modify_switch_result(1, .explore, .update, [Mock.experience("4")])
    }

    class ScenarioMaker {

        let mockApiRepo = MockExperienceApiRepo()
        let mockRequestersSwitch = ExperienceRequestersSwitchMock()
        let repo: ExperienceRepository

        var experiencesObservableResult: Observable<Result<[Experience]>>!
        var experienceObservableResult: Observable<Result<Experience>>!
        var stringObservableResult: Observable<Result<String>>!

        init() {
            repo = ExperienceRepoImplementation(apiRepo: mockApiRepo,
                                                requestersSwitch: mockRequestersSwitch,
                                                ioScheduler: MainScheduler.instance)
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
        
        func given_an_api_repo_that_returns_on_save(_ result: Result<Bool>) -> ScenarioMaker {
            mockApiRepo.apiSaveCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_translate(_ result: Result<String>) -> ScenarioMaker {
            mockApiRepo.apiTranslateShareIdCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_share_url(_ result: Result<String>) -> ScenarioMaker {
            mockApiRepo.apiShareUrlCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_experience(_ result: Result<Experience>) -> ScenarioMaker {
            mockApiRepo.apiExperienceCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_create(_ result: Result<Experience>) -> ScenarioMaker {
            mockApiRepo.createExperienceResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_edit(_ result: Result<Experience>) -> ScenarioMaker {
            mockApiRepo.editExperienceResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_upload_picture(_ result: Result<Experience>) -> ScenarioMaker {
            mockApiRepo.uploadPictureResult = Observable.just(result)
            return self
        }

        func when_getfirsts(_ kind: Kind, _ params: Request.Params) -> ScenarioMaker {
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

        func when_share_url(_ experienceId: String) -> ScenarioMaker {
            stringObservableResult = self.repo.shareUrl(experienceId)
            return self
        }

        func when_translate_share_id(_ experienceShareId: String) -> ScenarioMaker {
            stringObservableResult = repo.translateShareId(experienceShareId)
            return self
        }

        func when_refresh_experience(_ experienceId: String) -> ScenarioMaker {
            repo.refreshExperience(experienceId)
            return self
        }

        func when_create_experience(_ title: String, _ description: String) -> ScenarioMaker {
            experienceObservableResult = repo.createExperience(title, description)
            return self
        }

        func when_edit_experience(_ experienceId: String, _ title: String,
                                  _ description: String) -> ScenarioMaker {
            experienceObservableResult = repo.editExperience(experienceId, title, description)
            return self
        }

        func when_upload_picture(_ experienceId: String, _ image: UIImage) -> ScenarioMaker {
            repo.uploadPicture(experienceId, image)
            return self
        }

        func then_should_call_api_translate_share_url(_ experienceId: String) -> ScenarioMaker {
            stringObservableResult = repo.shareUrl(experienceId)
            return self
        }

        func then_should_call_api_save(_ experienceId: String) -> ScenarioMaker {
            assert(mockApiRepo.saveCalls.count == 1)
            assert(mockApiRepo.saveCalls[0].0 == experienceId)
            assert(mockApiRepo.saveCalls[0].1 == true)
            return self
        }

        func then_should_call_api_create(_ title: String, _ description: String) -> ScenarioMaker {
            assert(mockApiRepo.createExperienceCalls.count == 1)
            assert(mockApiRepo.createExperienceCalls[0].0 == title)
            assert(mockApiRepo.createExperienceCalls[0].1 == description)
            return self
        }

        func then_should_call_api_edit(_ experienceId: String, _ title: String,
                                         _ description: String) -> ScenarioMaker {
            assert(mockApiRepo.editExperienceCalls.count == 1)
            assert(mockApiRepo.editExperienceCalls[0].0 == experienceId)
            assert(mockApiRepo.editExperienceCalls[0].1 == title)
            assert(mockApiRepo.editExperienceCalls[0].2 == description)
            return self
        }

        func then_should_call_api_upload_picture(_ experienceId: String,
                                                 _ image: UIImage) -> ScenarioMaker {
            assert(mockApiRepo.uploadPictureCalls.count == 1)
            assert(mockApiRepo.uploadPictureCalls[0].0 == experienceId)
            assert(mockApiRepo.uploadPictureCalls[0].1 == image)
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
        func then_should_return_string_observable(_ expectedResult: Result<String>) -> ScenarioMaker {
            do { let result = try stringObservableResult.toBlocking().toArray()
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

        @discardableResult
        func then_should_call_api_translate_share_id(_ experienceShareId: String) -> ScenarioMaker {
            assert(mockApiRepo.translateShareIdCalls.count == 1)
            assert(mockApiRepo.translateShareIdCalls[0] == experienceShareId)
            return self
        }

        @discardableResult
        func then_should_call_api_share_url(_ experienceId: String) -> ScenarioMaker {
            assert(mockApiRepo.shareUrlCalls.count == 1)
            assert(mockApiRepo.shareUrlCalls[0] == experienceId)
            return self
        }

        @discardableResult
        func then_should_call_api_experience(_ experienceId: String) -> ScenarioMaker {
            assert(mockApiRepo.experienceObservableCalls == [experienceId])
            return self
        }
    }
}

class ExperienceRepoMock: ExperienceRepository {

    var returnExploreObservable: Observable<Result<[Experience]>>!
    var returnSavedObservable: Observable<Result<[Experience]>>!
    var returnMineObservable: Observable<Result<[Experience]>>!
    var returnPersonsObservable: Observable<Result<[Experience]>>!
    var returnOtherObservable: Observable<Result<[Experience]>>!
    var returnExperienceObservable: Observable<Result<Experience>>!
    var returnTranslateShareIdObservable: Observable<Result<String>>!
    var returnShareUrlObservable: Observable<Result<String>>!
    var experiencesObservableCalls = [Kind]()
    var getFirstsCalls = [(Kind, Request.Params?)]()
    var paginateCalls = [Kind]()
    var singleExperienceCalls = [String]()
    var saveCalls = [(String, Bool)]()
    var shareUrlCalls = [String]()
    var refreshExperienceCalls = [String]()
    var createExperienceCalls = [(String, String)]()
    var createExperienceResult: Observable<Result<Experience>>!
    var uploadPictureCalls = [(String, UIImage)]()
    var editExperienceCalls = [(String, String, String)]()
    var editExperienceResult: Observable<Result<Experience>>!

    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>> {
        switch kind {
        case .explore:
            return returnExploreObservable
        case .saved:
            return returnSavedObservable
        case .mine:
            return returnMineObservable
        case .persons:
            return returnPersonsObservable
        case .other:
            return returnOtherObservable
        }
    }

    func getFirsts(kind: Kind, params: Request.Params?) {
        self.getFirstsCalls.append((kind, params))
    }

    func paginate(kind: Kind) {
        self.paginateCalls.append(kind)
    }

    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        singleExperienceCalls.append(experienceId)
        return returnExperienceObservable
    }

    func refreshExperience(_ experienceId: String) {
        refreshExperienceCalls.append(experienceId)
    }

    func saveExperience(_ experienceId: String, save: Bool) {
        saveCalls.append((experienceId, save))
    }

    func translateShareId(_ shareId: String) -> Observable<Result<String>> {
        return returnTranslateShareIdObservable
    }

    func shareUrl(_ experienceId: String) -> Observable<Result<String>> {
        shareUrlCalls.append(experienceId)
        return returnShareUrlObservable
    }

    func createExperience(_ title: String, _ description: String) -> Observable<Result<Experience>> {
        createExperienceCalls.append((title, description))
        return createExperienceResult
    }

    func uploadPicture(_ experienceId: String, _ image: UIImage) {
        uploadPictureCalls.append((experienceId, image))
    }

    func editExperience(_ experienceId: String, _ title: String, _ description: String) -> Observable<Result<Experience>> {
        editExperienceCalls.append((experienceId, title, description))
        return editExperienceResult
    }
}
