//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 7.06.25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias RetrievalResult = Swift.Result<Data?, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
