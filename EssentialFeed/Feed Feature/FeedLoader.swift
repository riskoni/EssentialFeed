//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 10.12.23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
