//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Nikolay on 21.05.24.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore){
        
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    
}
