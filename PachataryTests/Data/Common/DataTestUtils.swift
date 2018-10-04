import Swift
import XCTest
import Hippolyte
@testable import Pachatary

class DataTestUtils {
    
    static func stubNetworkCall(_ testCase: XCTestCase, _ bundle: Bundle,
                                _ url: String, _ method: HTTPMethod, _ jsonFile: String?,
                                _ statusCode: Int = 200, _ requestBody: String? = nil) {
        let url = URL(string: url)!
        var stub = StubRequest(method: method, url: url)
        if requestBody != nil {
            let stubbedRequestBody = (requestBody!).data(using: .utf8)!
            stub.bodyMatcher = DataMatcher(data: stubbedRequestBody)
        }
        var response = StubResponse()

        var body = Data()
        if jsonFile != nil {
            let path = bundle.path(forResource: jsonFile, ofType: "json")
            do { body = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe) }
            catch { assertionFailure() }
        }

        response.statusCode = statusCode
        response.body = body
        stub.response = response
        Hippolyte.shared.add(stubbedRequest: stub)
        Hippolyte.shared.start()

        let expectation = testCase.expectation(description: "Stubs network call")
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            //XCTAssertEqual(data, body)
            expectation.fulfill()
        }
        task.resume()

        testCase.wait(for: [expectation], timeout: 1)
    }
}
