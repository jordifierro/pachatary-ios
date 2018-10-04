import Swift
import RxSwift

protocol ProfileRepository {
    func profile(_ username: String) -> Observable<Result<Profile>>
    func cache(_ profile: Profile)
}

class ProfileRepositoryImplementation: ProfileRepository {
    
    private let profileSubject: PublishSubject<Profile>
    private let profilesObservable: Observable<[Profile]>
    
    init() {
        profileSubject = PublishSubject<Profile>()
        profilesObservable = profileSubject.asObservable()
            .scan([], accumulator: { (oldProfiles: [Profile], newProfile: Profile) -> [Profile] in
                var newProfiles = oldProfiles.filter({ profile in profile.username != newProfile.username })
                newProfiles.append(newProfile)
                return newProfiles
            })
            .distinctUntilChanged()
            .replay(1)
            .autoconnect()
        let startConnectionDisposable = profilesObservable.subscribe({ event in
            switch event {
            case .error(let error):
                fatalError(error.localizedDescription)
            default: break
            }
        })
        startConnectionDisposable.dispose()
    }
    func profile(_ username: String) -> Observable<Result<Profile>> {
        return profilesObservable
            .map({ profiles in profiles.filter({ profile in profile.username == username }) })
            .map({ profiles in
                if profiles.isEmpty { return Result(error: DataError.notCached) }
                else { return Result(.success, data: profiles[0]) }
            })
            .distinctUntilChanged()
    }
    
    func cache(_ profile: Profile) {
        profileSubject.asObserver().onNext(profile)
    }
}
