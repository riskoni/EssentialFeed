//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.06.25.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve() throws -> CachedFeed? {
        try performSync { context in
            Result {
                try FeedEntity.find(in: context).map {
                    return CachedFeed(feed: $0.localFeedImages, timestamp: $0.timestamp!)
                }
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result {
                let entity = try FeedEntity.newUniqueInstance(in: context)
                entity.timestamp = timestamp
                entity.images = FeedImageEntity.images(from: feed, in: context)
                try context.save()
            }
        }
    }
    
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result {
                try FeedEntity.deleteCache(in: context)
            }
        }
    }
}
