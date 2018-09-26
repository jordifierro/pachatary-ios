import Swift

public struct Result<T: Equatable>: Equatable {
    
    enum ResultStatus {
        case success
        case error
        case inProgress
    }

    let status: ResultStatus
    let data: T?
    let error: DataError?
    let nextUrl: String?
    let action: Request.Action!
    let params: Request.Params?

    init(_ status: ResultStatus,
         data: T? = nil, nextUrl: String? = nil,
         action: Request.Action = .none,
         params: Request.Params? = nil,
         error: DataError? = nil) {
        self.status = status
        self.data = data
        self.error = error
        self.nextUrl = nextUrl
        self.action = action
        self.params = params
    }
    
    init(error: DataError) {
        self.status = .error
        self.data = nil
        self.error = error
        self.nextUrl = nil
        self.action = .none
        self.params = nil
    }
    
    func isInProgress() -> Bool { return (self.status == .inProgress) }
    func isSuccess() -> Bool { return (self.status == .success) }
    func isError() -> Bool { return (self.status == .error) }
    func hasBeenInitialized() -> Bool { return (self.action != Request.Action.none) }
    func hasMoreElements() -> Bool { return (self.nextUrl != nil) }
    func builder() -> Builder { return Builder(self) }
    
    public static func == (lhs: Result<T>, rhs: Result<T>) -> Bool {
        return lhs.status == rhs.status
            && lhs.data == rhs.data
            && lhs.error == rhs.error
            && lhs.nextUrl == rhs.nextUrl
            && lhs.action == rhs.action
            && lhs.params == rhs.params
    }
    
    class Builder {
        
        var status: ResultStatus
        var data: T?
        var error: DataError?
        var nextUrl: String?
        var action: Request.Action!
        var params: Request.Params?

        init(_ result: Result<T>) {
            self.status = result.status
            self.data = result.data
            self.error = result.error
            self.nextUrl = result.nextUrl
            self.action = result.action
            self.params = result.params
        }
        
        func action(_ action: Request.Action) -> Builder {
            self.action = action
            return self
        }
        
        func data(_ data: T) -> Builder {
            self.data = data
            return self
        }
        
        func status(_ status: ResultStatus) -> Builder {
            self.status = status
            return self
        }
        
        func error(_ error: DataError?) -> Builder {
            self.error = error
            return self
        }
        
        func params(_ params: Request.Params?) -> Builder {
            self.params = params
            return self
        }
        
        func build() -> Result<T> {
            return Result(self.status, data: self.data,
                          nextUrl: self.nextUrl, action: self.action, params: self.params,
                          error: self.error)
        }
    }
}


