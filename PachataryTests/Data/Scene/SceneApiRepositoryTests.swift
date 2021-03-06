import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class SceneApiRepositoryTests: XCTestCase {
    
    func test_scenes_parses_scenes_response() {
        ScenarioMaker(self)
            .given_an_experience_id()
            .given_an_stubbed_network_call_for_scenes_experience_id()
            .when_scenes_flowable_with_that_id()
            .then_should_return_flowable_with_inprogress_and_result_scenes()
    }

    func test_create_scene_parses_scene_response() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_for_create_scene()
            .when_create_scene()
            .then_should_return_flowable_with_inprogress_and_result_scene()
    }

    func test_upload_picture_parses_scene_reponse() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_for_upload_picture("9")
            .when_upload_picture("9")
            .then_should_return_flowable_with_inprogress_and_result_scene()
    }

    func test_edit_scene_parses_response() {
        //Cannot test because Hippolyte doesn't support PATCH method
    }

    class ScenarioMaker {
        let api = MoyaProvider<SceneApi>().rx
        var repo: SceneApiRepository!
        var testCase: XCTestCase!
        var resultScenesObservable: Observable<Result<[Scene]>>!
        var resultSceneObservable: Observable<Result<Scene>>!
        var paginationUrl = ""
        var experienceId = ""
        
        init(_ testCase: XCTestCase) {
            self.testCase = testCase
            repo = SceneApiRepoImplementation(api, MainScheduler.instance)
        }

        func given_an_experience_id() -> ScenarioMaker {
            self.experienceId = "9"
            return self
        }
        
        func given_an_stubbed_network_call_for_scenes_experience_id() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                  AppDataDependencyInjector.apiUrl + "/scenes/?experience=" + experienceId,
                  .GET, "GET_scenes_experience_id")
            return self
        }

        func given_an_stubbed_network_call_for_create_scene() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                                          AppDataDependencyInjector.apiUrl + "/scenes/",
                                          .POST, "POST_scenes")
            return self
        }

        func given_an_stubbed_network_call_for_upload_picture(_ sceneId: String) -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle(for: type(of: self)),
                  AppDataDependencyInjector.apiUrl + "/scenes/" + sceneId + "/picture",
                  .POST, "POST_scenes")
            return self
        }

        func when_scenes_flowable_with_that_id() -> ScenarioMaker {
            resultScenesObservable = repo.scenesObservable(experienceId: experienceId)
            return self
        }

        func when_create_scene() -> ScenarioMaker {
            resultSceneObservable = repo.createScene("", "", "", 0.0, 0.0)
            return self
        }

        func when_upload_picture(_ sceneId: String) -> ScenarioMaker {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
            UIColor.black.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            resultSceneObservable = repo.uploadPicture(sceneId, image)
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_scenes() -> ScenarioMaker {
            let expectedScenes = [
                Scene(id: "5",
                      title: "Plaça Mundial",
                      description: "World wide square!",
                      picture: BigPicture(smallUrl: "https://scenes/37d6.small.jpeg",
                                          mediumUrl: "https://scenes/37d6.medium.jpeg",
                                          largeUrl: "https://scenes/37d6.large.jpeg"),
                      latitude: 1.0,
                      longitude: 2.0,
                      experienceId: "5"),
                Scene(id: "4",
                      title: "I've been here",
                      description: "",
                      picture: nil,
                      latitude: 0.0,
                      longitude: 1.0,
                      experienceId: "5")]

            do { let result = try resultScenesObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedScenes) == result[1])
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_return_flowable_with_inprogress_and_result_scene() -> ScenarioMaker {
            let expectedScene =
                Scene(id: "5",
                      title: "Mundial",
                      description: "World wide square!",
                      picture: BigPicture(smallUrl: "https://scenes/37d6.small.jpeg",
                                          mediumUrl: "https://scenes/37d6.medium.jpeg",
                                          largeUrl: "https://scenes/37d6.large.jpeg"),
                      latitude: 1.0,
                      longitude: 2.0,
                      experienceId: "5")

            do { let result = try resultSceneObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedScene) == result[1])
            } catch { assertionFailure() }
            return self
        }
    }
}

class MockSceneApiRepo: SceneApiRepository {

    var resultScenesForExperienceId = [String:Result<[Scene]>]()
    var createSceneResult: Observable<Result<Scene>>!
    var createSceneCalls = [(String, String, String, Double, Double)]()
    var uploadPictureResult: Observable<Result<Scene>>!
    var uploadPictureCalls = [(String, Image)]()
    var editSceneResult: Observable<Result<Scene>>!
    var editSceneCalls = [(String, String, String, Double, Double)]()

    var calls = [String]()

    init() {}

    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        calls.append(experienceId)
        return Observable.just(resultScenesForExperienceId[experienceId]!)
    }

    func createScene(_ experienceId: String, _ title: String, _ description: String, _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        createSceneCalls.append((experienceId, title, description, latitude, longitude))
        return createSceneResult
    }

    func uploadPicture(_ sceneId: String, _ image: UIImage) -> Observable<Result<Scene>> {
        uploadPictureCalls.append((sceneId, image))
        return uploadPictureResult
    }

    func editScene(_ sceneId: String, _ title: String, _ description: String, _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        editSceneCalls.append((sceneId, title, description, latitude, longitude))
        return editSceneResult
    }
}
