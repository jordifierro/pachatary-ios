import Swift
import RxSwift

class ProfileSnifferExperienceApiRepo: ExperienceApiRepository {
    
    let realExperienceApiRepo: ExperienceApiRepository
    let profileRepo: ProfileRepository
    let sniffProfiles: (Result<[Experience]>) -> ()

    init(_ experienceApiRepo: ExperienceApiRepository,
         _ profileRepo: ProfileRepository) {
        self.realExperienceApiRepo = experienceApiRepo
        self.profileRepo = profileRepo
        
        sniffProfiles = { result in
            switch result.status {
            case .success:
                for experience in result.data! {
                    profileRepo.cache(experience.authorProfile)
                }
            default: break
            }
        }
    }
    
    func exploreExperiencesObservable(_ text: String?, _ latitude: Double?, _ longitude: Double?) -> Observable<Result<[Experience]>> {
        return self.realExperienceApiRepo.exploreExperiencesObservable(text, latitude, longitude)
            .do(onNext: sniffProfiles)
    }
    
    func savedExperiencesObservable() -> Observable<Result<[Experience]>> {
        return self.realExperienceApiRepo.savedExperiencesObservable()
            .do(onNext: sniffProfiles)
    }
    
    func personsExperiencesObservable(_ username: String) -> Observable<Result<[Experience]>> {
        return self.realExperienceApiRepo.personsExperiencesObservable(username)
            .do(onNext: sniffProfiles)
    }
    
    func paginateExperiences(_ url: String) -> Observable<Result<[Experience]>> {
        return self.realExperienceApiRepo.paginateExperiences(url)
            .do(onNext: sniffProfiles)
    }
    
    func saveExperience(_ experienceId: String, save: Bool) -> Observable<Result<Bool>> {
        return self.realExperienceApiRepo.saveExperience(experienceId, save: save)
    }
}
