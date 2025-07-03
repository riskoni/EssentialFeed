//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 04.07.25.
//

import Foundation

public final class RemoteLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void ){
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch(result){
            case let .success((data, response)):
                completion(RemoteLoader.map(data, response: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items)
        }catch {
            return .failure(Error.invalidData)
        }
    }
}
