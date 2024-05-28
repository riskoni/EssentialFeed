//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Nikolay on 25.05.24.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    public static let modelName = "FeedStore"
    public static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public struct ModelNotFound: Error {
        public let modelName: String
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
        }
        
        container = try NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: model,
            url: storeURL
        )
        context = container.newBackgroundContext()
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
  
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
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
        let context = self.context
        context.perform {
            
            try? CoreDataFeedStore.deleteAllFeedEntities(context: context)
            
            do{
                try CoreDataFeedStore.saveFeedEntity(feed: feed, timestamp: timestamp, in: context)
                completion(nil)
            }catch {
                context.rollback()
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = self.context
        context.perform {            
            do{
                try CoreDataFeedStore.deleteAllFeedEntities(context: context)
                completion(nil)
            }catch {
                context.rollback()
                completion(error)
            }
        }
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
    
    private static func toRetrievaResult(_ feedEntity: FeedEntity?) -> FeedStore.RetrievalResult {
        guard let feedEntity = feedEntity else {
            return .success(.none)
        }
        let images = feedEntity.images?.compactMap { ($0 as? FeedImageEntity)?.toLocalFeedImage() } ?? []
        return .success(CachedFeed(feed: images, timestamp: feedEntity.timestamp!))
    }
}

extension Array<LocalFeedImage> {
    
    func toFeedImageEntites(context: NSManagedObjectContext) -> [FeedImageEntity] {
        map {
            let entity = FeedImageEntity(context: context)
            
            entity.id = $0.id
            entity.descriptionText = $0.description
            entity.location = $0.location
            entity.url = $0.url
            
            return entity
        }
    }
}

extension FeedImageEntity {
    
    func toLocalFeedImage() -> LocalFeedImage? {
        return LocalFeedImage(
            id: id!,
            description: descriptionText,
            location: location,
            url: url!
        )
    }
}


