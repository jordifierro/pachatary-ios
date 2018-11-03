import XCTest
import RxSwift
import RxBlocking
import Hippolyte
import Moya
@testable import Pachatary

class SingleNetworkResponseTransformerTests: XCTestCase {
    
    func test_maps_object() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_success()
            .when_call_fake_request()
            .then_should_map_json_response_to_domain_object()
    }

    func test_when_error_retries_3_times() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_error()
            .when_call_fake_request()
            .then_should_retry_3_times_and_throw_error()
    }

    func test_catches_no_internet_connection_errors() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_no_internet_connection_error()
            .when_call_fake_request()
            .then_should_catch_error_and_emit_error_result()
    }
    
    func test_emits_in_progress_on_start() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_success()
            .when_call_fake_request()
            .then_should_emit_inprogress_result_on_start()
    }
    
    func test_maps_object_list() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_success_list()
            .when_call_fake_request_list()
            .then_should_map_json_response_to_domain_object_list()
    }
    
    func test_when_error_retries_3_times_list() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_error()
            .when_call_fake_request_list()
            .then_should_retry_3_times_and_throw_error_list()
    }
    
    func test_catches_no_internet_connection_errors_list() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_no_internet_connection_error()
            .when_call_fake_request_list()
            .then_should_catch_error_and_emit_error_result_list()
    }
    
    func test_emits_in_progress_on_start_list() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_success_list()
            .when_call_fake_request_list()
            .then_should_emit_inprogress_result_on_start_list()
    }

    func test_void_error_mapper() {
        ScenarioMaker(self)
            .given_an_stubbed_network_call_that_returns_body_with_an_error()
            .when_call_fake_with_error()
            .then_should_emit_client_error_result()
    }

    class ScenarioMaker {
        
        var testCase: XCTestCase!
        var resultBoolObservable: Observable<Result<Bool>>!
        var resultObservable: Observable<Result<AuthToken>>!
        var resultListObservable: Observable<Result<[Scene]>>!
        let fakeRepo = FakeApiRepository()
        var error: NSError!
        
        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }

        func given_an_stubbed_network_call_that_returns_success() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle.init(for: type(of: self)),
                AppDataDependencyInjector.apiUrl + "/people/", .POST, "POST_people",
                201, "client_secret_key=")
            return self
        }
        
        func given_an_stubbed_network_call_that_returns_success_list() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle.init(for: type(of: self)),
                AppDataDependencyInjector.apiUrl + "/people/", .POST, "GET_scenes_experience_id",
                201, "client_secret_key=")
            return self
        }

        func given_an_stubbed_network_call_that_returns_body_with_an_error() -> ScenarioMaker {
            DataTestUtils.stubNetworkCall(testCase, Bundle.init(for: type(of: self)),
                                          AppDataDependencyInjector.apiUrl + "/people/", .POST, "PATCH_people_me_ERROR",
                                          402, "client_secret_key=")
            return self

        }
        
        func given_an_stubbed_network_call_that_returns_error() -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl + "/people/")!
            let requestBody = ("client_secret_key=").data(using: .utf8)!
            var stub = StubRequest(method: .POST, url: url)
            stub.bodyMatcher = DataMatcher(data: requestBody)
            let response = StubResponse.Builder().stubResponse(withError:
                NSError(domain: "fake error", code: -1, userInfo: nil)).build()
            
            stub.response = response
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.start()
            
            let expectation = testCase.expectation(description: "Stubs network call")
            expectation.expectedFulfillmentCount = 4
            let task = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task.resume()
            let task2 = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task2.resume()
            let task3 = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task3.resume()
            let task4 = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task4.resume()
            
            testCase.wait(for: [expectation], timeout: 1)
            return self
        }
        
        func given_an_stubbed_network_call_that_returns_no_internet_connection_error()
                                                                                  -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl + "/people/")!
            let requestBody = ("client_secret_key=").data(using: .utf8)!
            var stub = StubRequest(method: .POST, url: url)
            stub.bodyMatcher = DataMatcher(data: requestBody)
            let response = StubResponse.Builder().stubResponse(withError:
                NSError(domain: "no internet error", code: -1009, userInfo: nil)).build()
            
            stub.response = response
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.start()
            
            let expectation = testCase.expectation(description: "Stubs network call")
            expectation.expectedFulfillmentCount = 4
            let task = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task.resume()
            let task2 = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task2.resume()
            let task3 = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task3.resume()
            let task4 = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task4.resume()

            testCase.wait(for: [expectation], timeout: 1)
            return self
        }

        func when_call_fake_request() -> ScenarioMaker {
            resultObservable = fakeRepo.fakeRequest()
            return self
        }

        func when_call_fake_request_list() -> ScenarioMaker {
            resultListObservable = fakeRepo.fakeRequestList()
            return self
        }

        func when_call_fake_with_error() -> ScenarioMaker {
            resultBoolObservable = fakeRepo.fakeRequestWithErrorHandling()
            return self
        }

        @discardableResult
        func then_should_map_json_response_to_domain_object() -> ScenarioMaker {
            do {
                let result = try resultObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
                assert(result[1] == Result(.success, data:
                    AuthToken(accessToken: "A_T_12345", refreshToken: "R_T_67890")))
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_map_json_response_to_domain_object_list() -> ScenarioMaker {
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
            
            do { let result = try resultListObservable.toBlocking().toArray()
                assert(result.count == 2)
                assert(Result(.inProgress) == result[0])
                assert(Result(.success, data: expectedScenes) == result[1])
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_retry_3_times_and_throw_error() -> ScenarioMaker {
            let errorExceptation = testCase.expectation(description: "wait for error")
            _ = resultObservable
                .skip(1)
                .catchError({ error in
                    errorExceptation.fulfill()
                    return Observable.empty()
                })
                .subscribe { event in
                    switch event {
                    case .next(_): assertionFailure()
                    case .error(_): assertionFailure()
                    case .completed: break
                    }
                }
            
            testCase.wait(for: [errorExceptation], timeout: 0.1)
            return self
        }
        
        @discardableResult
        func then_should_retry_3_times_and_throw_error_list() -> ScenarioMaker {
            let errorExceptation = testCase.expectation(description: "wait for error")
            _ = resultListObservable
                .skip(1)
                .catchError({ error in
                    errorExceptation.fulfill()
                    return Observable.empty()
                })
                .subscribe { event in
                    switch event {
                    case .next(_): assertionFailure()
                    case .error(_): assertionFailure()
                    case .completed: break
                    }
            }
            
            testCase.wait(for: [errorExceptation], timeout: 0.1)
            return self
        }
        
        @discardableResult
        func then_should_catch_error_and_emit_error_result() -> ScenarioMaker {
            do {
                let result = try resultObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
                assert(result[1] == Result(.error, error: DataError.noInternetConnection))
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_catch_error_and_emit_error_result_list() -> ScenarioMaker {
            do {
                let result = try resultListObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
                assert(result[1] == Result(.error, error: DataError.noInternetConnection))
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_emit_inprogress_result_on_start() -> ScenarioMaker {
            do {
                let result = try resultObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
            } catch { assertionFailure() }
            return self
        }
        
        @discardableResult
        func then_should_emit_inprogress_result_on_start_list() -> ScenarioMaker {
            do {
                let result = try resultListObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
            } catch { assertionFailure() }
            return self
        }

        @discardableResult
        func then_should_emit_client_error_result() -> ScenarioMaker {
            do {
                let result = try resultBoolObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
                assert(result[1] == Result(.error, error:
                    DataError.clientException(source: "person", code: "already_registered", message: "Person already registered")))
            } catch { assertionFailure() }
            return self
        }
    }
}

class FakeApiRepository {
    
    let api: Reactive<MoyaProvider<AuthApi>>! = MoyaProvider<AuthApi>().rx
    let clientSecretKey = ""
    let ioScheduler = MainScheduler.instance

    func fakeRequestWithErrorHandling() -> Observable<Result<Bool>> {
        return self.api.request(.createPerson(clientSecretKey: clientSecretKey))
            .transformNetworkVoidResponseOrError(ioScheduler)
    }
    
    func fakeRequest() -> Observable<Result<AuthToken>> {
        return self.api.request(.createPerson(clientSecretKey: clientSecretKey))
            .transformNetworkResponse(SingleResultMapper<AuthTokenMapper>.self, ioScheduler)
    }
    
    func fakeRequestList() -> Observable<Result<[Scene]>> {
        return self.api.request(.createPerson(clientSecretKey: clientSecretKey))
            .transformNetworkListResponse(SceneMapper.self, ioScheduler)
    }
}
