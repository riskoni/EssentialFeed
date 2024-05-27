//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Nikolay on 22.05.24.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult)->Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch the appropriate threads, if needed:
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch the appropriate threads, if needed:
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch the appropriate threads, if needed:
    func retrieve(completion: @escaping RetrievalCompletion)
}
