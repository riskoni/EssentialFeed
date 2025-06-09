//
//  FeedEntity.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.06.25.
//

import CoreData

extension FeedEntity {
    static func find(in context: NSManagedObjectContext) throws -> FeedEntity? {
        let request = NSFetchRequest<FeedEntity>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> FeedEntity {
        try find(in: context).map(context.delete)
        return FeedEntity(context: context)
    }
    
//    var localFeed: [LocalFeedImage] {
//        return images.compactMap { ($0 as? FeedImageEntity)?.local }
//    }
}
