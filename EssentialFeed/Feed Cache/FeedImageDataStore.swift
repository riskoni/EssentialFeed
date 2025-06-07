//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 7.06.25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias Result = Swift.Result<Data?, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
