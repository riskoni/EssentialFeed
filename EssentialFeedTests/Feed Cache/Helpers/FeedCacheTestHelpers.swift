//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Nikolay on 24.05.24.
//

import Foundation
import EssentialFeed

func uniqueFeed() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueFeed(), uniqueFeed()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.description, url: $0.url )}
    return (models, local)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
}

