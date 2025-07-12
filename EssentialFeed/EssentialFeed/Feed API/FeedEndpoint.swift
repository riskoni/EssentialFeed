//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 12.07.25.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
