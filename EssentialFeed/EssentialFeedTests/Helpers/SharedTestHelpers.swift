//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Nikolay on 24.05.24.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
