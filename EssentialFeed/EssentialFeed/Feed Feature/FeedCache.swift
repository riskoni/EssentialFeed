//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 10.06.25.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
