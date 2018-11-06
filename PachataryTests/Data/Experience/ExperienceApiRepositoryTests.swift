import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class ExperienceApiRepositoryTests: XCTestCase {
    
    func test_get_experiences_search_parses_experiences_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_search("museum", 2.4, -1.3)
            .when_experiences_flowable("museum", 2.4, -1.3)
            .then_should_return_flowable_with_inprogress_and_result_experiences()
    }
    
    func test_get_saved_experiences_parses_experiences_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_saved()
            .when_saved_experiences_flowable()
            .then_should_return_flowable_with_inprogress_and_result_experiences()
    }

    func test_get_persons_experiences_parses_experiences_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_persons("username")
            .when_persons_experiences_flowable("username")
            .then_should_return_flowable_with_inprogress_and_result_experiences()
    }

    func test_paginate_experiences_parses_experiences_response() {
        ScenarioMaker(self).buildScenario()
            .given_a_pagination_url()
            .given_an_stubbed_network_call_for_pagination()
            .when_paginate_experiences_flowable()
            .then_should_return_flowable_with_inprogress_and_result_experiences()
    }
    
    func test_save_experience() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_save("6", method: .POST, statusCode: 201)
            .when_save("6", save: true)
            .then_should_return_flowable_with_inprogress_and_result_success()
    }
    
    func test_unsave_experience() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_save("6", method: .DELETE, statusCode: 204)
            .when_save("6", save: false)
            .then_should_return_flowable_with_inprogress_and_result_success()
    }

    func test_translate_share_id() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_translate_share_id("some_share_id")
            .when_translate_share_id("some_share_id")
            .then_should_return_flowable_with_inprogress_and_result_experience_id()
    }

    func test_get_experience_parses_experience_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_experience("4")
            .when_experience_flowable("4")
            .then_should_return_flowable_with_inprogress_and_result_experience()
    }

    func test_share_url_parses_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_share_url("4")
            .when_share_url("4")
            .then_should_return_flowable_with_inprogress_and_result_share_url()
    }

    func test_create_experience_parses_experience_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_experience_create()
            .when_create_experience("title", "desc")
            .then_should_return_flowable_with_inprogress_and_result_experience()
    }

    func test_upload_picture_parses_experience_response() {
        ScenarioMaker(self).buildScenario()
            .given_an_stubbed_network_call_for_upload_picture("5")
            .when_upload_picture("5")
            .then_should_return_flowable_with_inprogress_and_result_experience()
    }

    func test_edit_experience_parses_experience_response() {
        //Cannot test PATCH due to Hippolyte
    }

    class ScenarioMaker {
        let api = MoyaProvider<ExperienceApi>().rx
        var repo: ExperienceApiRepository!
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<[Experience]>>!
        var experienceObservable: Observable<Result<Experience>>!
        var saveResultObservable: Observable<Result<Bool>>!
        var stringResultObservable: Observable<Result<String>>!
        var paginationUrl = ""
        
        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }

        func buildScenario() -> ScenarioMaker {
            repo = ExperienceApiRepoImplementation(api, MainScheduler.instance)
            return self
        }
        
        func given_a_pagination_url() -> ScenarioMaker {
            paginationUrl = "http://domain/path?query=some"
            return self
        }
        
        func given_an_stubbed_network_call_for_search(_ searchText: String,
                                                      _ latitude: Double,
                                                      _ longitude: Double) -> ScenarioMaker {
            let latitudeString: String = String(format:"%.1f", latitude)
            let longitudeString: String = String(format:"%.1f", longitude)
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                                          AppDataDependencyInjector.apiUrl +
                                            "/experiences/search?" +
                                            "latitude=" + latitudeString +
                                            "&longitude=" + longitudeString +
                                            "&word=" + searchText,
                                          .GET, "GET_experiences")
            return self
        }

        func given_an_stubbed_network_call_for_saved() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                  AppDataDependencyInjector.apiUrl + "/experiences/?saved=true",
                  .GET, "GET_experiences")
            return self
        }

        func given_an_stubbed_network_call_for_translate_share_id(
            _ experienceShareId: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                                          AppDataDependencyInjector.apiUrl + "/experiences/" +
                                          experienceShareId + "/id",
                                          .GET, "GET_experience_share_id")
            return self

        }

        func given_an_stubbed_network_call_for_share_url(_ experienceId: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                                          AppDataDependencyInjector.apiUrl + "/experiences/" +
                                            experienceId + "/share-url",
                                          .GET, "GET_experience_share_url")
            return self

        }

        func given_an_stubbed_network_call_for_persons(_ username: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                                          AppDataDependencyInjector.apiUrl +
                                            "/experiences/?username=" + username,
                                          .GET, "GET_experiences")
            return self
        }

        func given_an_stubbed_network_call_for_experience(_ experienceId: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                                          AppDataDependencyInjector.apiUrl +
                                            "/experiences/" + experienceId,
                                          .GET, "GET_experience")
            return self
        }

        func given_an_stubbed_network_call_for_experience_create() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                                          AppDataDependencyInjector.apiUrl +
                                            "/experiences/",
                                          .POST, "POST_experiences")
            return self
        }

        func given_an_stubbed_network_call_for_upload_picture(_ experienceId: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of:self)),
                                          AppDataDependencyInjector.apiUrl +
                "/experiences/" + experienceId + "/picture",
                                          .POST, "POST_experiences_id_picture")
            return self
        }

        func given_an_stubbed_network_call_for_pagination() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                                          self.paginationUrl, .GET, "GET_experiences")
            return self
        }
        
        func given_an_stubbed_network_call_for_save(_ experienceId: String, method: HTTPMethod,
                                                    statusCode: Int) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                  AppDataDependencyInjector.apiUrl + "/experiences/" + experienceId + "/save",
                  method, nil, statusCode)
            return self
        }
        
        func when_experiences_flowable(_ searchText: String, _ latitude: Double,
                                       _ longitude: Double) -> ScenarioMaker {
            resultObservable = repo.exploreExperiencesObservable(searchText, latitude, longitude)
            return self
        }
        
        func when_saved_experiences_flowable() -> ScenarioMaker {
            resultObservable = repo.savedExperiencesObservable()
            return self
        }

        func when_persons_experiences_flowable(_ username: String) -> ScenarioMaker {
            resultObservable = repo.personsExperiencesObservable(username)
            return self
        }

        func when_paginate_experiences_flowable() -> ScenarioMaker {
            resultObservable = repo.paginateExperiences(paginationUrl)
            return self
        }
        
        func when_save(_ experienceId: String, save: Bool) -> ScenarioMaker {
            saveResultObservable = repo.saveExperience(experienceId, save: save)
            return self
        }

        func when_translate_share_id(_ experienceShareId: String) -> ScenarioMaker {
            stringResultObservable = repo.translateShareId(experienceShareId)
            return self
        }

        func when_experience_flowable(_ experienceId: String) -> ScenarioMaker {
            experienceObservable = repo.experienceObservable(experienceId)
            return self
        }

        func when_create_experience(_ title: String, _ description: String) -> ScenarioMaker {
            experienceObservable = repo.createExperience(title, description)
            return self
        }

        func when_share_url(_ experienceId: String) -> ScenarioMaker {
            stringResultObservable = repo.shareUrl(experienceId)
            return self
        }

        func when_upload_picture(_ experienceId: String) -> ScenarioMaker {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
            UIColor.black.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            experienceObservable = repo.uploadPicture(experienceId, image)
            return self
        }
        
        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_experiences() -> ScenarioMaker {
            let expectedExperiences = [
                Experience(id: "3", title: "Magic Castle of Lost Swamps",
                    description: "Don't even try to go there!", picture: nil, isMine: true,
                    isSaved: false,
                    authorProfile: Profile(username: "da_usr", bio: "about me",
                                           picture: nil, isMe: true),
                           savesCount: 5),
                Experience( id: "2", title: "Baboóon", description: "Mystical place...",
                    picture: BigPicture(smallUrl: "https://experiences/8c29.small.jpg",
                                        mediumUrl: "https://experiences/8c29.medium.jpg",
                                        largeUrl: "https://experiences/8c29.large.jpg"),
                    isMine: false, isSaved: true,
                    authorProfile: Profile(username: "usr.nam", bio: "user info",
                                           picture: LittlePicture(
                                            tinyUrl: "https://profiles/029d.tiny.jpg",
                                            smallUrl: "https://profiles/029d.small.jpg",
                                            mediumUrl: "https://profiles/029d.medium.jpg"),
                                           isMe: false),
                                           savesCount: 32)]
            let expectedNextUrl = "https://base_url/experiences/?mine=false&saved=false&limit=2&offset=2"
            
            do { let result = try resultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedExperiences, nextUrl: expectedNextUrl) == result[1])
            } catch {
                assertionFailure()
            }
            return self
        }
        
        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_success() -> ScenarioMaker {
            do { let result = try saveResultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: true) == result[1])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_experience_id() -> ScenarioMaker {
            do { let result = try stringResultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: "A2D4") == result[1])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_share_url() -> ScenarioMaker {
            do { let result = try stringResultObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: "http://domain.com/experiences/4S") == result[1])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_experience() -> ScenarioMaker {
            let expectedExperience =
                Experience( id: "2", title: "Baboóon", description: "Mystical place...",
                            picture: BigPicture(smallUrl: "https://experiences/8c29.small.jpg",
                                                mediumUrl: "https://experiences/8c29.medium.jpg",
                                                largeUrl: "https://experiences/8c29.large.jpg"),
                            isMine: false, isSaved: true,
                            authorProfile: Profile(username: "usr.nam", bio: "user info",
                                                   picture: LittlePicture(
                                                    tinyUrl: "https://profiles/029d.tiny.jpg",
                                                    smallUrl: "https://profiles/029d.small.jpg",
                                                    mediumUrl: "https://profiles/029d.medium.jpg"),
                                                   isMe: false),
                            savesCount: 32)

            do { let result = try experienceObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedExperience) == result[1])
            }
            catch { assertionFailure() }
            return self
        }
    }
}

class MockExperienceApiRepo: ExperienceApiRepository {

    var apiExploreCallResultObservable: Observable<Result<[Experience]>>?
    var apiSavedCallResultObservable: Observable<Result<[Experience]>>?
    var apiPersonsCallResultObservable: Observable<Result<[Experience]>>?
    var apiPaginateCallResultObservable: Observable<Result<[Experience]>>?
    var apiSaveCallResultObservable: Observable<Result<Bool>>?
    var apiTranslateShareIdCallResultObservable: Observable<Result<String>>?
    var apiExperienceCallResultObservable: Observable<Result<Experience>>?
    var apiShareUrlCallResultObservable: Observable<Result<String>>?
    var saveCalls = [(String, Bool)]()
    var translateShareIdCalls = [String]()
    var shareUrlCalls = [String]()
    var experienceObservableCalls = [String]()
    var createExperienceCalls = [(String, String)]()
    var createExperienceResult: Observable<Result<Experience>>?
    var uploadPictureCalls = [(String, UIImage)]()
    var uploadPictureResult: Observable<Result<Experience>>?
    var editExperienceCalls = [(String, String, String)]()
    var editExperienceResult: Observable<Result<Experience>>?

    init() {}

    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?,
                                      _ longitude: Double?) -> Observable<Result<[Experience]>> {
        return apiExploreCallResultObservable!
    }

    func savedExperiencesObservable() -> Observable<Result<[Experience]>> {
        return apiSavedCallResultObservable!
    }

    func personsExperiencesObservable(_ username: String) -> Observable<Result<[Experience]>> {
        return apiPersonsCallResultObservable!
    }

    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return apiPaginateCallResultObservable!
    }

    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>> {
        saveCalls.append((experienceId, save))
        return apiSaveCallResultObservable!
    }

    func translateShareId(_ experienceShareId: String) -> Observable<Result<String>> {
        translateShareIdCalls.append(experienceShareId)
        return apiTranslateShareIdCallResultObservable!
    }

    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        experienceObservableCalls.append(experienceId)
        return apiExperienceCallResultObservable!
    }

    func shareUrl(_ experienceId: String) -> Observable<Result<String>> {
        shareUrlCalls.append(experienceId)
        return apiShareUrlCallResultObservable!
    }

    func createExperience(_ title: String, _ description: String) -> Observable<Result<Experience>> {
        createExperienceCalls.append((title, description))
        return createExperienceResult!
    }

    func uploadPicture(_ experienceId: String, _ image: UIImage) -> Observable<Result<Experience>> {
        uploadPictureCalls.append((experienceId, image))
        return uploadPictureResult!
    }

    func editExperience(_ experienceId: String, _ title: String, _ description: String) -> Observable<Result<Experience>> {
        editExperienceCalls.append((experienceId, title, description))
        return editExperienceResult!
    }
}
