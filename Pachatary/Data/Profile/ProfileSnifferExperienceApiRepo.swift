import Swift
import RxSwift

class ProfileSnifferExperienceApiRepo: ExperienceApiRepository {

    let realExperienceApiRepo: ExperienceApiRepository
    let profileRepo: ProfileRepository
    let sniffProfiles: (Result<[Experience]>) -> ()
    let sniffProfile: (Result<Experience>) -> ()

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

        sniffProfile = { result in
            switch result.status {
            case .success:
                profileRepo.cache(result.data!.authorProfile)
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

    func translateShareId(_ experienceShareId: String) -> Observable<Result<String>> {
        return self.realExperienceApiRepo.translateShareId(experienceShareId)
    }

    func experienceObservable(_ experienceId: String) -> Observable<Result<Experience>> {
        return self.realExperienceApiRepo.experienceObservable(experienceId)
            .do(onNext: sniffProfile)
    }

    func shareUrl(_ experienceId: String) -> Observable<Result<String>> {
        return self.realExperienceApiRepo.shareUrl(experienceId)
    }

    func createExperience(_ title: String, _ description: String) -> Observable<Result<Experience>> {
        return self.realExperienceApiRepo.createExperience(title, description)
            .do(onNext: sniffProfile)
    }

    func uploadPicture(_ experienceId: String, _ image: UIImage) -> Observable<Result<Experience>> {
        return self.realExperienceApiRepo.uploadPicture(experienceId, image)
            .do(onNext: sniffProfile)
    }

    func editExperience(_ experienceId: String, _ title: String, _ description: String) -> Observable<Result<Experience>> {
        return self.realExperienceApiRepo.editExperience(experienceId, title, description)
            .do(onNext: sniffProfile)
    }

    func flagExperience(_ experienceId: String, _ reason: String) -> Observable<Result<Bool>> {
        return self.realExperienceApiRepo.flagExperience(experienceId, reason)
    }
}
