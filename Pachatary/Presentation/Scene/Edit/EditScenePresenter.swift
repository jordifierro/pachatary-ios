import UIKit
import RxSwift

class EditScenePresenter {

    let repo: SceneRepository
    let mainScheduler: ImmediateSchedulerType
    unowned let view: EditSceneView
    let experienceId: String
    let sceneId: String

    let disposeBag = DisposeBag()

    init(_ sceneRepository: SceneRepository,
         _ mainScheduler: ImmediateSchedulerType,
         _ view: EditSceneView,
         _ experienceId: String,
         _ sceneId: String) {
        self.repo = sceneRepository
        self.mainScheduler = mainScheduler
        self.view = view
        self.experienceId = experienceId
        self.sceneId = sceneId
    }

    func create() {
        getScene()
    }

    func retry() {
        getScene()
    }

    func addPictureButtonClick() {
        view.navigateToPickAndCropImage()
    }

    func selectLocationButtonClick() {
        view.navigateToSelectLocation()
    }

    func updateButtonClick() {
        if view.latitude() == nil || view.longitude() == nil { view.showNoLocationError() }
        else if view.title().count == 0 || view.title().count > 80 { view.showTitleLengthError() }
        else if view.description().count == 0 { view.showNoDescriptionError() }
        else {
            repo.editScene(sceneId,
                           view.title(), view.description(),
                           view.latitude()!, view.longitude()!)
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let result):
                        switch result.status {
                        case .success:
                            if self.view.picture() != nil {
                                self.repo.uploadPicture(self.sceneId, self.view.picture()!)
                                self.view.showSuccessAndUploadingPicture()
                            }
                            else { self.view.showSuccess() }
                            self.view.finish()
                        case .error:
                            self.view.hideLoader()
                            self.view.showError()
                            self.view.enableUpdateButton()
                        case .inProgress:
                            self.view.showLoader()
                            self.view.disableUpdateButton()
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

    private func getScene() {
        repo.sceneObservable(experienceId: experienceId, sceneId: sceneId)
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.fillSceneData(result.data!)
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
