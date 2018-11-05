import Swift
import RxSwift

protocol ProfileRepository {
    func profile(_ username: String) -> Observable<Result<Profile>>
    func selfProfile() -> Observable<Result<Profile>>
    func cache(_ profile: Profile)
    func uploadProfilePicture(_ image: UIImage) -> Observable<Result<Profile>>
}

class ProfileRepositoryImplementation: ProfileRepository {

    let apiRepo: ProfileApiRepository
    let ioScheduler: ImmediateSchedulerType
    private let profileSubject: PublishSubject<Profile>
    private let profilesObservable: Observable<[Profile]>
    
    init(_ profileApiRepo: ProfileApiRepository,
         _ ioScheduler: ImmediateSchedulerType) {
        self.apiRepo = profileApiRepo
        self.ioScheduler = ioScheduler
        profileSubject = PublishSubject<Profile>()
        profilesObservable = profileSubject.asObservable()
            .scan([], accumulator: { (oldProfiles: [Profile], newProfile: Profile) -> [Profile] in
                var newProfiles = oldProfiles.filter({ profile in profile.username != newProfile.username })
                newProfiles.append(newProfile)
                return newProfiles
            })
            .startWith([])
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
                if profiles.isEmpty { return Result(.error, error: DataError.notCached) }
                else { return Result(.success, data: profiles[0]) }
            })
            .flatMap { (result: Result<Profile>) -> Observable<Result<Profile>> in
                if result.error == DataError.notCached {
                    return self.apiRepo.profileObservable(username).do(onNext:
                        { result in if result.status == .success { self.cache(result.data!) } })
                }
                else { return Observable.just(result) }
            }
            .distinctUntilChanged()
    }

    func selfProfile() -> Observable<Result<Profile>> {
        return profilesObservable
            .map({ profiles in profiles.filter({ profile in profile.isMe }) })
            .map({ profiles in
                if profiles.isEmpty { return Result(.error, error: DataError.notCached) }
                else { return Result(.success, data: profiles[0]) }
            })
            .flatMap { (result: Result<Profile>) -> Observable<Result<Profile>> in
                if result.error == DataError.notCached {
                    return self.apiRepo.profileObservable("self").do(onNext:
                        { result in if result.status == .success { self.cache(result.data!) } })
                }
                else { return Observable.just(result) }
            }
            .distinctUntilChanged()
    }

    func uploadProfilePicture(_ image: UIImage) -> Observable<Result<Profile>> {
        return apiRepo.uploadProfilePicture(image)
            .do(onNext: { result in
                switch result.status {
                case .success:
                    self.cache(result.data!)
                default:
                    break
                }
            })
    }

    func cache(_ profile: Profile) {
        profileSubject.asObserver().onNext(profile)
    }
}
