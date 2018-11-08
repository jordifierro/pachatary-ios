import UIKit
import TTGSnackbar

class Snackbar {

    enum Duration {
        case short
        case long
        case infinite
    }

    private static let errorMessage = "Oops! Something went wrong. Please try again".localized()

    static func show(_ message: String, _ duration: Duration) {
        let snackbar = TTGSnackbar(message: message, duration: getTTGSnackbarDuration(duration))
        snackbar.show()
    }

    static func showError() {
        let snackbar = TTGSnackbar(message: errorMessage, duration: .middle)
        snackbar.show()
    }

    static func showErrorWithRetry(_ retryDelegate: @escaping () -> ()) {
        let snackbar = TTGSnackbar(message: errorMessage, duration: .forever,
                                   actionText: "RETRY".localized(),
                                   actionBlock: { snackbar in
                                                    retryDelegate()
                                                    snackbar.dismiss()
                                                })
        snackbar.show()
    }

    private static func getTTGSnackbarDuration(_ duration: Duration) -> TTGSnackbarDuration {
        switch duration {
        case .short:
            return TTGSnackbarDuration.middle
        case .long:
            return TTGSnackbarDuration.long
        case .infinite:
            return TTGSnackbarDuration.forever
        }
    }
}
