import Swift

struct Result<T: Equatable> {
    
    enum ResultStatus {
        case success
        case error
        case inProgress
    }

    let status: ResultStatus
    let data: T?
    let error: DataError?

    init(_ status: ResultStatus) {
        self.status = status
        self.data = nil
        self.error = nil
    }
    
    init(_ status: ResultStatus, data: T? = nil, error: DataError? = nil) {
        self.status = status
        self.data = data
        self.error = error
    }
    
    static func == (lhs: Result<T>, rhs: Result<T>) -> Bool {
        return lhs.status == rhs.status && lhs.data == rhs.data
    }
}


