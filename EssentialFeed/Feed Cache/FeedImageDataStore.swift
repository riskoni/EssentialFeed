//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 7.06.25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
