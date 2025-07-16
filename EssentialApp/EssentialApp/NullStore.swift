//
//  NullStore.swift
//  EssentialApp
//
//  Created by Nikolay Riskov on 12.07.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class NullStore {}

extension NullStore: FeedStore {
    func deleteCachedFeed() throws {}
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    
    func retrieve() throws -> CachedFeed? { .none }
}

extension NullStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {}
    
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
