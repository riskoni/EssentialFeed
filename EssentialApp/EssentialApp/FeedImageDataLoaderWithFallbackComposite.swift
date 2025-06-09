//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Nikolay Riskov on 9.06.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {

        }
    }

    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = primary.loadImageData(from: url) { _ in }
        return Task()
    }
}
