import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

protocol ExperienceApiRepository {
    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?, _ longitude: Double?)
                                                                -> Observable<Result<[Experience]>>
    func savedExperiencesObservable() -> Observable<Result<[Experience]>>
    func personsExperiencesObservable(_ username: String) -> Observable<Result<[Experience]>>
    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>>
    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>>
    func translateShareId(_ experienceShareId: String) -> Observable<Result<String>>
    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>>
    func shareUrl(_ experienceId: String) -> Observable<Result<String>>
    func createExperience(_ title: String, _ description: String) -> Observable<Result<Experience>>
    func uploadPicture(_ experienceId: String, _ image: UIImage) -> Observable<Result<Experience>>
    func editExperience(_ experienceId: String,
                        _ title: String, _ description: String) -> Observable<Result<Experience>>
    func flagExperience(_ experienceId: String, _ reason: String) -> Observable<Result<Bool>>
}

class ExperienceApiRepoImplementation: ExperienceApiRepository {

    let api: Reactive<MoyaProvider<ExperienceApi>>!
    let ioScheduler: ImmediateSchedulerType!

    init(_ api: Reactive<MoyaProvider<ExperienceApi>>, _ ioScheduler: ImmediateSchedulerType!) {
        self.api = api
        self.ioScheduler = ioScheduler
    }
    
    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?,
                                      _ longitude: Double?) -> Observable<Result<[Experience]>> {
        return self.api.request(.search(text ?? "", latitude, longitude))
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }
    
    func savedExperiencesObservable() -> Observable<Result<[Experience]>> {
        return self.api.request(.saved)
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func personsExperiencesObservable(_ username: String) -> Observable<Result<[Experience]>> {
        return self.api.request(.persons(username))
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return self.api.request(.paginate(url))
            .transformNetworkResponse(PaginatedListResultMapper<ExperienceMapper>.self, ioScheduler)
    }
    
    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>> {
        return self.api.request(.save(experienceId, save))
            .transformNetworkVoidResponse(ioScheduler)
    }

    func translateShareId(_ experienceShareId: String) -> Observable<Result<String>> {
        return self.api.request(.translateShareId(experienceShareId))
            .transformNetworkResponse(SingleResultMapper<ExperienceIdMapper>.self, ioScheduler)
    }

    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return self.api.request(.experience(experienceId))
            .transformNetworkResponseOrError(SingleResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func shareUrl(_ experienceId: String) -> Observable<Result<String>> {
        return self.api.request(.shareUrl(experienceId))
            .transformNetworkResponse(SingleResultMapper<ExperienceShareUrlMapper>.self, ioScheduler)
    }

    func createExperience(_ title: String, _ description: String) -> Observable<Result<Experience>> {
        return self.api.request(.create(title: title, description: description))
            .transformNetworkResponse(SingleResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func uploadPicture(_ experienceId: String, _ image: UIImage) -> Observable<Result<Experience>> {
        return self.api.request(.uploadPicture(experienceId: experienceId, picture: image))
            .transformNetworkResponse(SingleResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func editExperience(_ experienceId: String,
                        _ title: String, _ description: String) -> Observable<Result<Experience>> {
        return self.api.request(.edit(id: experienceId, title: title, description: description))
            .transformNetworkResponse(SingleResultMapper<ExperienceMapper>.self, ioScheduler)
    }

    func flagExperience(_ experienceId: String, _ reason: String) -> Observable<Result<Bool>> {
        return self.api.request(.flag(id: experienceId, reason: reason))
            .transformNetworkVoidResponse(ioScheduler)
    }
}
