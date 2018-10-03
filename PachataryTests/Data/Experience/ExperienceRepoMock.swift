import Swift
import RxSwift

@testable import Pachatary

class ExperienceRepoMock: ExperienceRepository {

    var returnExploreObservable: Observable<Result<[Experience]>>!
    var returnSavedObservable: Observable<Result<[Experience]>>!
    var returnExperienceObservable: Observable<Result<Experience>>!
    var experiencesObservableCalls = [Kind]()
    var getFirstsCalls = [(Kind, Request.Params?)]()
    var paginateCalls = [Kind]()
    var singleExperienceCalls = [String]()
    var saveCalls = [(String, Bool)]()
    
    func experiencesObservable(kind: Kind) -> Observable<Result<[Experience]>> {
        switch kind {
        case .explore:
            return returnExploreObservable
        case .saved:
            return returnSavedObservable
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
    
    func saveExperience(_ experienceId: String, save: Bool) {
        saveCalls.append((experienceId, save))
    }
}
