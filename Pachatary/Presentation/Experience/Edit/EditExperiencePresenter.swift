import UIKit
import RxSwift

class EditExperiencePresenter {

    let repo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    unowned let view: EditExperienceView
    let experienceId: String
    let disposeBag = DisposeBag()

    init(_ experienceRepository: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: EditExperienceView,
         _ experienceId: String) {
        self.repo = experienceRepository
        self.mainScheduler = mainScheduler
        self.view = view
        self.experienceId = experienceId
    }

    func create() {
        getExperience()
    }

    func retry() {
        getExperience()
    }

    func addPictureButtonClick() {
        view.navigateToPickAndCropImage()
    }

    func updateButtonClick() {
        if view.title().count == 0 || view.title().count > 80 { view.showTitleLengthError() }
        else if view.description().count == 0 { view.showNoDescriptionError() }
        else {
            repo.editExperience(experienceId, view.title(), view.description())
                .observeOn(mainScheduler)
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let result):
                        switch result.status {
                        case .success:
                            self.view.hideLoader()
                            if self.view.picture() != nil {
                                self.repo.uploadPicture(self.experienceId, self.view.picture()!)
                                self.view.showSuccessAndUploadingPicture()
                            }
                            else { self.view.showSuccess() }
                            self.view.finish()
                        case .error:
                            self.view.enableUpdateButton()
                            self.view.hideLoader()
                            self.view.showError()
                        case .inProgress:
                            self.view.disableUpdateButton()
                            self.view.showLoader()
                        }
                    case .error(let error):
                        fatalError(error.localizedDescription)
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
    }

    private func getExperience() {
        repo.experienceObservable(experienceId)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.fillExperienceData(result.data!)
                        self.view.enableUpdateButton()
                        self.view.hideLoader()
                    case .error:
                        self.view.disableUpdateButton()
                        self.view.hideLoader()
                        self.view.showRetry()
                    case .inProgress:
                        self.view.disableUpdateButton()
                        self.view.showLoader()
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
