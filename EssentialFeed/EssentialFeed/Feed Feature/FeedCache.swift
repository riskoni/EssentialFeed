//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 10.06.25.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
