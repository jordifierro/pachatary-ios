import Swift

enum DataError: Error {
    case noLoggedPerson
    case noInternetConnection
}

extension DataError: Equatable {
    static func == (lhs: DataError, rhs: DataError) -> Bool {
        switch (lhs, rhs) {
        case (.noLoggedPerson, .noLoggedPerson):
            return true
        case (.noInternetConnection, .noInternetConnection):
            return true
        default:
            return false
        }
    }
}

