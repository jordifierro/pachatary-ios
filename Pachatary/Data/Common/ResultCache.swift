import Swift
import RxSwift

protocol ResultCache {
    associatedtype cacheType: Identifiable & Equatable
    
    func replaceResult(_ result: Result<[cacheType]>)
    func addOrUpdate(_ list: [cacheType])
    func update(_ list: [cacheType])
    var resultObservable: Observable<Result<[cacheType]>> { get }
}

class ResultCacheImplementation<T: Identifiable & Equatable>: ResultCache {

    private let replaceResultObserver: AnyObserver<Result<[T]>>
    private let addOrUpdateObserver: AnyObserver<[T]>
    private let updateObserver: AnyObserver<[T]>
    let resultObservable: Observable<Result<[T]>>
    
    init() {
        let replaceResultSubject = PublishSubject<Result<[T]>>()
        replaceResultObserver = replaceResultSubject.asObserver()
        let addOrUpdateSubject = PublishSubject<[T]>()
        addOrUpdateObserver = addOrUpdateSubject.asObserver()
        let updateSubject = PublishSubject<[T]>()
        updateObserver = updateSubject.asObserver()
        
        let resultConnectable = Observable.merge(
            replaceResultSubject.asObservable()
                .map { (newResult: Result<[T]>) -> ((Result<[T]>) -> Result<[T]>) in
                    return { _ in return newResult }},
            addOrUpdateSubject.asObservable()
                .map { (newList: [T]) -> ((Result<[T]>) -> Result<[T]>) in
                    return { oldResult in
                        var updatedList = newList
                        for elem in oldResult.data! {
                            let duplicatedIndex = updatedList.index(where:
                            { (item: Identifiable) in return (elem.id == item.id) })
                            if duplicatedIndex == nil { updatedList.append(elem) }
                        }
                        return Result(.success, data: updatedList)
                    }},
            updateSubject.asObservable()
                .map { (newList: [T]) -> ((Result<[T]>) -> Result<[T]>) in
                    return { oldResult in
                        var updatedList = oldResult.data!
                        for elem in newList {
                            let duplicatedIndex = updatedList.index(where:
                            { (item: Identifiable) in return (elem.id == item.id) })
                            if duplicatedIndex != nil { updatedList[duplicatedIndex!] = elem }
                        }
                        return Result(.success, data: updatedList)
                    }})
            .scan(Result<[T]>(.success, data: []),
                   accumulator:
                { (oldValue: Result<[T]>, function: ((Result<[T]>) -> Result<[T]>)) in
                    return function(oldValue)
            })
            .startWith(Result<[T]>(.success, data: []))
            .replay(1)
        resultObservable = resultConnectable
        _ = resultConnectable.connect()
    }

    func replaceResult(_ result: Result<[T]>) {
        replaceResultObserver.onNext(result)
    }

    func addOrUpdate(_ list: [T]) {
        addOrUpdateObserver.onNext(list)
    }

    func update(_ list: [T]) {
        updateObserver.onNext(list)
    }
}
