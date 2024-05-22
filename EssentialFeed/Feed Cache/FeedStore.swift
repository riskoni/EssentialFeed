//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Nikolay on 22.05.24.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
