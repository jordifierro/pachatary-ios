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
    
    class ScenarioMaker {
        
        var testCase: XCTestCase!
        var resultObservable: Observable<Result<AuthToken>>!
        let fakeRepo = FakeApiRepository()
        var error: NSError!
        
        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }

        func given_an_stubbed_network_call_that_returns_success() -> ScenarioMaker {
            let url = URL(string: AppDataDependencyInjector.apiUrl + "/people/")!
            let requestBody = ("client_secret_key=").data(using: .utf8)!
            var stub = StubRequest(method: .POST, url: url)
            stub.bodyMatcher = DataMatcher(data: requestBody)
            var response = StubResponse()
            
            var body = Data()
            let path = Bundle(for: type(of: self)).path(forResource: "POST_people", ofType: "json")
            do { body = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe) }
            catch { assertionFailure() }
            
            response.body = body
            stub.response = response
            Hippolyte.shared.add(stubbedRequest: stub)
            Hippolyte.shared.start()
            
            let expectation = testCase.expectation(description: "Stubs network call")
            let task = URLSession.shared.dataTask(with: url) { data, response, _ in
                expectation.fulfill()
            }
            task.resume()
            
            testCase.wait(for: [expectation], timeout: 1)
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
        func then_should_catch_error_and_emit_error_result() -> ScenarioMaker {
            do {
                let result = try resultObservable.toBlocking().toArray()
                assert(result[0] == Result(.inProgress))
                assert(result[1] == Result(error: DataError.noInternetConnection))
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
    }
}

class FakeApiRepository {
    
    let api: Reactive<MoyaProvider<AuthApi>>! = MoyaProvider<AuthApi>().rx
    let clientSecretKey = ""
    let ioScheduler = MainScheduler.instance
    
    func fakeRequest() -> Observable<Result<AuthToken>> {
        return self.api.request(.createPerson(clientSecretKey: clientSecretKey))
            .transformNetworkResponse(ResultSingleMapper<AuthTokenMapper>.self, ioScheduler)
    }
}
