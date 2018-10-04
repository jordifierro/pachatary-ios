import Swift

enum DataError: Error {
    case noLoggedPerson
    case noInternetConnection
    case notCached
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
        default:
            return false
        }
    }
}

