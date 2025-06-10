//
//  FeedLoaderStub.swift
//  EssentialApp
//
//  Created by Nikolay Riskov on 10.06.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    public init(result: FeedLoader.Result) {
        self.result = result
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
