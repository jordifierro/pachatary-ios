import Swift
import XCTest
import RxSwift
@testable import Pachatary

class ProfileSnifferExperienceApiRepoTests: XCTestCase {
    
    func test_explore_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_explore(
                Result(.success, data: [Mock.experience("1", authorProfile: Mock.profile("a")),
                                        Mock.experience("2", authorProfile: Mock.profile("b"))]))
            .when_explore_experiences()
            .then_should_sniff([Mock.profile("a"), Mock.profile("b")])
    }
    
    func test_saved_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_saved(
                Result(.success, data: [Mock.experience("1", authorProfile: Mock.profile("a")),
                                        Mock.experience("2", authorProfile: Mock.profile("b"))]))
            .when_saved_experiences()
            .then_should_sniff([Mock.profile("a"), Mock.profile("b")])
    }
    
    func test_persons_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_persons(
                Result(.success, data: [Mock.experience("1", authorProfile: Mock.profile("a")),
                                        Mock.experience("2", authorProfile: Mock.profile("b"))]))
            .when_persons_experiences()
            .then_should_sniff([Mock.profile("a"), Mock.profile("b")])
    }
    
    func test_pagination_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_pagination(
                Result(.success, data: [Mock.experience("1", authorProfile: Mock.profile("a")),
                                        Mock.experience("2", authorProfile: Mock.profile("b"))]))
            .when_pagination_experiences()
            .then_should_sniff([Mock.profile("a"), Mock.profile("b")])
    }
    
    func test_save_is_not_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_save(Result(.success, data: true))
            .when_save_experience()
            .then_should_sniff([])
    }

    func test_translate_share_id_is_not_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_translate_share_id(Result(.success, data: "id"))
            .when_translate_share_id("share_id")
            .then_should_sniff([])
    }

    func test_experience_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_experience(Result(.success, data: Mock.experience("1", authorProfile: Mock.profile("u"))))
            .when_experience("1")
            .then_should_sniff([Mock.profile("u")])
    }

    func test_share_url_is_not_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_share_url(Result(.success, data: "url"))
            .when_share_url("4")
            .then_should_sniff([])
    }

    func test_create_experience_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_create_experience(Result(.success, data: Mock.experience("1", authorProfile: Mock.profile("u"))))
            .when_create_experience("t", "d")
            .then_should_sniff([Mock.profile("u")])
    }

    func test_edit_experience_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_edit_experience(Result(.success, data: Mock.experience("1", authorProfile: Mock.profile("u"))))
            .when_edit_experience("1", "t", "d")
            .then_should_sniff([Mock.profile("u")])
    }

    func test_upload_picture_experience_is_sniffed() {
        ScenarioMaker()
            .given_an_api_repo_that_returns_on_upload_picture(Result(.success, data: Mock.experience("1", authorProfile: Mock.profile("u"))))
            .when_upload_picture("7", UIImage())
            .then_should_sniff([Mock.profile("u")])
    }

    class ScenarioMaker {
        
        let sniffer: ProfileSnifferExperienceApiRepo
        var mockExperienceApiRepo = MockExperienceApiRepo()
        var mockProfileRepo = ProfileRepositoryMock()
        
        init() {
            sniffer = ProfileSnifferExperienceApiRepo(mockExperienceApiRepo, mockProfileRepo)
        }
        
        func given_an_api_repo_that_returns_on_explore(_ result: Result<[Experience]>) -> ScenarioMaker {
            mockExperienceApiRepo.apiExploreCallResultObservable = Observable.just(result)
            return self
        }
        
        func given_an_api_repo_that_returns_on_saved(_ result: Result<[Experience]>) -> ScenarioMaker {
            mockExperienceApiRepo.apiSavedCallResultObservable = Observable.just(result)
            return self
        }
        
        func given_an_api_repo_that_returns_on_persons(_ result: Result<[Experience]>) -> ScenarioMaker {
            mockExperienceApiRepo.apiPersonsCallResultObservable = Observable.just(result)
            return self
        }
        
        func given_an_api_repo_that_returns_on_pagination(_ result: Result<[Experience]>) -> ScenarioMaker {
            mockExperienceApiRepo.apiPaginateCallResultObservable = Observable.just(result)
            return self
        }
        
        func given_an_api_repo_that_returns_on_save(_ result: Result<Bool>) -> ScenarioMaker {
            mockExperienceApiRepo.apiSaveCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_translate_share_id(_ result: Result<String>) -> ScenarioMaker {
            mockExperienceApiRepo.apiTranslateShareIdCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_experience(_ result: Result<Experience>) -> ScenarioMaker {
            mockExperienceApiRepo.apiExperienceCallResultObservable = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_create_experience(_ result: Result<Experience>) -> ScenarioMaker {
            mockExperienceApiRepo.createExperienceResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_edit_experience(_ result: Result<Experience>) -> ScenarioMaker {
            mockExperienceApiRepo.editExperienceResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_upload_picture(_ result: Result<Experience>) -> ScenarioMaker {
            mockExperienceApiRepo.uploadPictureResult = Observable.just(result)
            return self
        }

        func given_an_api_repo_that_returns_on_share_url(_ result: Result<String>) -> ScenarioMaker {
            mockExperienceApiRepo.apiShareUrlCallResultObservable = Observable.just(result)
            return self
        }
        
        func when_explore_experiences() -> ScenarioMaker {
            _ = sniffer.exploreExperiencesObservable(nil, nil, nil).subscribe()
            return self
        }
        
        func when_saved_experiences() -> ScenarioMaker {
            _ = sniffer.savedExperiencesObservable().subscribe()
            return self
        }
        
        func when_persons_experiences() -> ScenarioMaker {
            _ = sniffer.personsExperiencesObservable("some").subscribe()
            return self
        }
        
        func when_pagination_experiences() -> ScenarioMaker {
            _ = sniffer.paginateExperiences("url").subscribe()
            return self
        }
        
        func when_save_experience() -> ScenarioMaker {
            _ = sniffer.saveExperience("2", save: true).subscribe()
            return self
        }

        func when_translate_share_id(_ experienceShareId: String) -> ScenarioMaker {
            _ = sniffer.translateShareId(experienceShareId).subscribe()
            return self
        }

        func when_experience(_ experienceId: String) -> ScenarioMaker {
            _ = sniffer.experienceObservable(experienceId).subscribe()
            return self
        }

        func when_create_experience(_ title: String, _ description: String) -> ScenarioMaker {
            _ = sniffer.createExperience(title, description).subscribe()
            return self
        }

        func when_edit_experience(_ experienceId: String, _ title: String,
                                  _ description: String) -> ScenarioMaker {
            _ = sniffer.editExperience(experienceId, title, description).subscribe()
            return self
        }

        func when_upload_picture(_ experienceId: String,
                                 _ image: UIImage) -> ScenarioMaker {
            _ = sniffer.uploadPicture(experienceId, image).subscribe()
            return self
        }

        func when_share_url(_ experienceId: String) -> ScenarioMaker {
            _ = sniffer.shareUrl(experienceId).subscribe()
            return self
        }

        @discardableResult
        func then_should_sniff(_ profiles: [Profile]) -> ScenarioMaker {
            assert(mockProfileRepo.cacheCalls == profiles)
            return self
        }
    }
}


