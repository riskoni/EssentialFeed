//
//  FeedImageEntity.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.06.25.
//

import Foundation
import CoreData

extension FeedImageEntity {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> FeedImageEntity? {
        let request = NSFetchRequest<FeedImageEntity>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(FeedImageEntity.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
