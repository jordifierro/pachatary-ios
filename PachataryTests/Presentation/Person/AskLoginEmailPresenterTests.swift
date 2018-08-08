import XCTest
import RxSwift
@testable import Pachatary

class AskLoginEmailPresenterTests: XCTestCase {
    
    func test_on_inprogress_disables_button() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.inProgress))
            .when_ask_login(email: "a")
            .then_should_disable_button()
    }
    
    func test_on_error_enables_button() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(error: .noInternetConnection))
            .when_ask_login(email: "a")
            .then_should_enable_button()
    }
    
    func test_on_success_finishes_app() {
        ScenarioMaker()
            .given_an_auth_repo_that_returns(Result(.success))
            .when_ask_login(email: "a")
            .then_should_finish_app()
    }

    class ScenarioMaker {
        let mockView = AskLoginEmailViewMock()
        let mockAuthRepo = AuthRepoMock()
        var presenter: AskLoginEmailPresenter!
        
        init() {
            presenter = AskLoginEmailPresenter(mockAuthRepo, MainScheduler.instance)
            presenter.view = mockView
        }
        
        func given_an_auth_repo_that_returns(_ result: Result<Bool>) -> ScenarioMaker {
            mockAuthRepo.askLoginEmailResult = result
            return self
        }
        
        func when_ask_login(email: String) -> ScenarioMaker {
            presenter.onAskClick(email)
            return self
        }
        
        @discardableResult
        func then_should_disable_button() -> ScenarioMaker {
            assert(mockView.disableButtonCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_enable_button() -> ScenarioMaker {
            assert(mockView.enableButtonCalls == 1)
            return self
        }
        
        @discardableResult
        func then_should_finish_app() -> ScenarioMaker {
            assert(mockView.finishAppCalls == 1)
            return self
        }
    }
}

class AskLoginEmailViewMock: AskLoginEmailView {
    
    var enableButtonCalls = 0
    var disableButtonCalls = 0
    var finishAppCalls = 0
    
    func enableButton() { enableButtonCalls += 1 }
    func disableButton() { disableButtonCalls += 1 }
    func finishApp() { finishAppCalls += 1 }
}


