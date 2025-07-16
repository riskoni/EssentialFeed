//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Nikolay on 25.05.24.
//

import CoreData

public final class CoreDataFeedStore {
    public static let modelName = "FeedStore"
    public static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public enum ContextQueue {
        case main
        case background
    }
    
    public init(storeURL: URL, contextQueue: ContextQueue = .background) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(
                name: CoreDataFeedStore.modelName,
                model: model,
                url: storeURL)
            context = contextQueue == .main ? container.viewContext : container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
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
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    public func perform(_ action: @escaping () -> Void) {
        context.perform(action)
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

#if os(iOS)

extension FeedEntity {
    
    static func className() -> String {
        return String(describing: self)
    }
    
}

#endif

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


