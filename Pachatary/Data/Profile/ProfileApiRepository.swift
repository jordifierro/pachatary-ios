import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol ProfileApiRepository {
    func profileObservable(_ username: String) -> Observable<Result<Profile>>
    func uploadProfilePicture(_ image: UIImage) -> Observable<Result<Profile>>
    func editProfile(_ bio: String) -> Observable<Result<Profile>>
}

class ProfileApiRepoImplementation: ProfileApiRepository {

    let api: Reactive<MoyaProvider<ProfileApi>>!
    let ioScheduler: ImmediateSchedulerType!

    init(_ api: Reactive<MoyaProvider<ProfileApi>>, _ ioScheduler: ImmediateSchedulerType!) {
        self.api = api
        self.ioScheduler = ioScheduler
    }

    func profileObservable(_ username: String) -> Observable<Result<Profile>> {
        return self.api.request(.profile(username))
            .transformNetworkResponse(SingleResultMapper<ProfileMapper>.self, ioScheduler)
    }

    func uploadProfilePicture(_ image: UIImage) -> Observable<Result<Profile>> {
        return self.api.request(.uploadPicture(picture: image))
            .transformNetworkResponse(SingleResultMapper<ProfileMapper>.self, ioScheduler)
    }

    func editProfile(_ bio: String) -> Observable<Result<Profile>> {
        return self.api.request(.editProfile(bio: bio))
            .transformNetworkResponse(SingleResultMapper<ProfileMapper>.self, ioScheduler)
    }
}
