//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Nikolay Riskov on 10.06.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
