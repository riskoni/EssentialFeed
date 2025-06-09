//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Nikolay Riskov on 9.06.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    public init (primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
