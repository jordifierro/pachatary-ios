import UIKit
import RxSwift

class CreateExperiencePresenter {

    let repo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    unowned let view: CreateExperienceView
    let disposeBag = DisposeBag()

    init(_ experienceRepository: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: CreateExperienceView) {
        self.repo = experienceRepository
        self.mainScheduler = mainScheduler
        self.view = view
    }

    func addPictureButtonClick() {
        view.navigateToPickAndCropImage()
    }

    func createButtonClick() {
        if view.picture() == nil { view.showNoPictureError() }
        else if view.title().count == 0 || view.title().count > 80 { view.showTitleLengthError() }
        else if view.description().count == 0 { view.showNoDescriptionError() }
        else {
            repo.createExperience(view.title(), view.description())
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let result):
                        switch result.status {
                        case .success:
                            self.repo.uploadPicture(result.data!.id, self.view.picture()!)
                            self.view.showSuccessAndUploadingPicture()
                            self.view.finish()
                        case .error:
                            self.view.hideLoader()
                            self.view.showError()
                            self.view.enableCreateButton()
                        case .inProgress:
                            self.view.showLoader()
                            self.view.disableCreateButton()
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
}
