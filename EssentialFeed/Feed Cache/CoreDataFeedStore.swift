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
        let request = NSFetchRequest<FeedEntity>(entityName: FeedEntity.className())
        do{
            let feedEntity = try context.fetch(request).last
            guard let feedEntity = feedEntity else {
                return completion(.empty)
            }
            let feed = feedEntity.images?.compactMap { ($0 as? FeedImageEntity)?.toLocalFeedImage() } ?? []
            completion(.found(feed: feed, timestamp: feedEntity.timestamp!))
            
        } catch {
            completion(.failure(error))
        }
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let feedEntity = FeedEntity(context: context)
        feedEntity.timestamp = timestamp
        feedEntity.images = NSOrderedSet(array: feed.toFeedImageEntites(context: context))        
        do{
            try context.save()
            completion(nil)
        }catch {
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do{
            let request = NSFetchRequest<FeedEntity>(entityName: FeedEntity.className())
            try context.fetch(request).forEach {
                context.delete($0)
                try context.save()
            }
            completion(nil)
        }catch {
            completion(error)
        }
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


