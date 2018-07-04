import Swift
import RxSwift

@testable import Pachatary

class ExperienceRepoMock: ExperienceRepository {

    var returnExperiences: [Experience]!
    var returnExperience = [String:Result<Experience>]()
    var returnInProgress = false
    var returnAction = Request.Action.getFirsts
    var returnError: DataError? = nil
    var getFirstsCalls = [Kind]()
    var paginateCalls = [Kind]()
    var singleExperienceCalls = [String]()
    var saveCalls = [String]()
    
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>> {
        assert(kind == .explore)
        var result: Result<[Experience]>?
        if returnInProgress { result = Result(.inProgress, data: nil,
                                              nextUrl: nil, action: returnAction) }
        else if returnError != nil { result = Result(error: returnError!) }
        else { result =  Result(.success, data: returnExperiences)}
        return Observable.just(result!)
    }
    
    func getFirsts(kind: Kind) {
        self.getFirstsCalls.append(kind)
    }
    
    func paginate(kind: Kind) {
        self.paginateCalls.append(kind)
    }
    
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        singleExperienceCalls.append(experienceId)
        return Observable.just(returnExperience[experienceId]!)
    }
    
    func switchExperienceSaveState(_ experienceId: String) {
        saveCalls.append(experienceId)
    }
}
