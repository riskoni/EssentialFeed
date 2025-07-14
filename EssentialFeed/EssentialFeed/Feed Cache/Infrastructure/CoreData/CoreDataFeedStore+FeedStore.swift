//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.06.25.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            let request = NSFetchRequest<FeedEntity>(entityName: FeedEntity.className())
            request.returnsObjectsAsFaults = false
            do{
                let feedEntity = try context.fetch(request).last
                completion(CoreDataFeedStore.toRetrievaResult(feedEntity))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            
            try? CoreDataFeedStore.deleteAllFeedEntities(context: context)
            
            do{
                try CoreDataFeedStore.saveFeedEntity(feed: feed, timestamp: timestamp, in: context)
                completion(.success(()))
            }catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            do{
                try CoreDataFeedStore.deleteAllFeedEntities(context: context)
                completion(.success(()))
            }catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    private static func toRetrievaResult(_ feedEntity: FeedEntity?) -> FeedStore.RetrievalResult {
        guard let feedEntity = feedEntity else {
            return .success(.none)
        }
        let images = feedEntity.images?.compactMap { ($0 as? FeedImageEntity)?.toLocalFeedImage() } ?? []
        return .success(CachedFeed(feed: images, timestamp: feedEntity.timestamp!))
    }
    
    private static func saveFeedEntity(feed: [LocalFeedImage], timestamp: Date, in context: NSManagedObjectContext) throws {
        let feedEntity = FeedEntity(context: context)
        feedEntity.timestamp = timestamp
        feedEntity.images = NSOrderedSet(array: feed.toFeedImageEntites(context: context))
        try context.save()
    }
    
    private static func deleteAllFeedEntities(context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<FeedEntity>(entityName: FeedEntity.className())
        try context.fetch(request).forEach {
            context.delete($0)
            try context.save()
        }
    }
}
