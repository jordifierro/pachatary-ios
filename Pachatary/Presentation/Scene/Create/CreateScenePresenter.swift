import UIKit
import RxSwift

class CreateScenePresenter {

    let repo: SceneRepository
    let mainScheduler: ImmediateSchedulerType
    unowned let view: CreateSceneView
    let experienceId: String

    let disposeBag = DisposeBag()

    init(_ sceneRepository: SceneRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: CreateSceneView,
         _ experienceId: String) {
        self.repo = sceneRepository
        self.mainScheduler = mainScheduler
        self.view = view
        self.experienceId = experienceId
    }

    func create() {
        view.tryToFindLastKnownLocation()
    }

    func addPictureButtonClick() {
        view.navigateToPickAndCropImage()
    }

    func selectLocationButtonClick() {
        if view.latitude() != nil {
            view.navigateToSelectLocation(view.latitude(), view.longitude())
        }
        else if view.lastKnownLatitude() != nil {
            view.navigateToSelectLocation(view.lastKnownLatitude(), view.lastKnownLongitude())
        }
        else {
            view.navigateToSelectLocation(nil, nil)
        }
    }

    func createButtonClick() {
        if view.picture() == nil { view.showNoPictureError() }
        else if view.latitude() == nil || view.longitude() == nil { view.showNoLocationError() }
        else if view.title().count == 0 || view.title().count > 80 { view.showTitleLengthError() }
        else if view.description().count == 0 { view.showNoDescriptionError() }
        else {
            repo.createScene(experienceId,
                             view.title(), view.description(),
                             view.latitude()!, view.longitude()!)
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
