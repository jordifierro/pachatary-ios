import Swift

enum DataError: Error {
    case noLoggedPerson
    case noInternetConnection
    case notCached
    case clientException(source: String, code: String, message: String)
    case serverError
}

extension DataError: Equatable {
    static func == (lhs: DataError, rhs: DataError) -> Bool {
        switch (lhs, rhs) {
        case (.noLoggedPerson, .noLoggedPerson):
            return true
        case (.noInternetConnection, .noInternetConnection):
            return true
        case (.notCached, .notCached):
            return true
        case (.clientException(let lhsSource, let lhsCode, let lhsMessage),
              .clientException(let rhsSource, let rhsCode, let rhsMessage)):
            return lhsSource == rhsSource && lhsCode == rhsCode && lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

