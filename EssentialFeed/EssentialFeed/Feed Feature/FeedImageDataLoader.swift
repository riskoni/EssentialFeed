//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 25.05.25.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
