import Swift
import RxSwift

@testable import Pachatary

class SceneRepoMock: SceneRepository {
    
    var scenesObservableCalls = [String]()
    var resultSceneForExperience = [String:Result<[Scene]>]()
    
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        scenesObservableCalls.append(experienceId)
        return Observable.just(resultSceneForExperience[experienceId]!)
    }
}
