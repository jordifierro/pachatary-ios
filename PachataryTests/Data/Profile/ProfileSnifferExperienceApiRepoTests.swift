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
        
        @discardableResult
        func then_should_sniff(_ profiles: [Profile]) -> ScenarioMaker {
            assert(mockProfileRepo.cacheCalls == profiles)
            return self
        }
    }
}


