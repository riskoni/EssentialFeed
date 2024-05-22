//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Nikolay on 22.05.24.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    
    public init(store: FeedStore, currentDate: @escaping ()->Date){
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?)->Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            }else{
                self.cache(items: items, with: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (Error?)->Void) {
        store.insertItems(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
