import Swift

enum DataError: Error {
    case noLoggedPerson
}

extension DataError: Equatable {
    static func == (lhs: DataError, rhs: DataError) -> Bool {
        switch (lhs, rhs) {
        case (.noLoggedPerson, .noLoggedPerson):
            return true
        default:
            return false
        }
    }
}

