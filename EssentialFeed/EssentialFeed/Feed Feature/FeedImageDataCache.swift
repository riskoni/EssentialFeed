//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 11.06.25.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
