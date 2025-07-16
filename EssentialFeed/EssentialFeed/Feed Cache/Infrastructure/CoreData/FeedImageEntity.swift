//
//  FeedImageEntity.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.06.25.
//

import Foundation
import CoreData

extension FeedImageEntity {
    
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let data = context.userInfo[url] as? Data { return data }
        
        return try first(with: url, in: context)?.data
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> FeedImageEntity? {
        let request = NSFetchRequest<FeedImageEntity>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(FeedImageEntity.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeed.map { local in
            let managed = FeedImageEntity(context: context)
            managed.id = local.id
            managed.descriptionText = local.description
            managed.location = local.location
            managed.url = local.url
            managed.data = context.userInfo[local.url] as? Data
            return managed
        })
        context.userInfo.removeAllObjects()
        return images
    }
    
    override public func prepareForDeletion() {
        super.prepareForDeletion()
        
        if let url = url {
            managedObjectContext?.userInfo[url] = data
        }
    }
}
