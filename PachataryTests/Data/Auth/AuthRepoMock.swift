import Swift
import RxSwift

@testable import Pachatary

class AuthRepoMock: AuthRepository {
    
    var hasPersonCredentialsResponse: Bool!
    var authToken: AuthToken!
    var returnInProgress = false
    var returnError: DataError? = nil
    var returnResult: Result<AuthToken>? = nil
    
    func hasPersonCredentials() -> Bool {
        return self.hasPersonCredentialsResponse
    }
    
    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        if returnResult != nil { return Observable.just(returnResult!) }
        var result: Result<AuthToken>?
        if returnInProgress { result = Result(.inProgress) }
        else if returnError != nil { result = Result(error: returnError!) }
        else { result =  Result(.success, data: authToken)}
        return Observable.just(result!)
    }
}
