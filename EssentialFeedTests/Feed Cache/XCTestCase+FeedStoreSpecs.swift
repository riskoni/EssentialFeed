//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Nikolay on 25.05.24.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {

    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp){ error in
            insertionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    func deleteCache(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedReuslt: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve: expectedReuslt, file: file, line: line)
        expect(sut, toRetrieve: expectedReuslt, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedReuslt: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve{ retrievalResult in
            switch (expectedReuslt, retrievalResult) {
            case (.empty, .empty):
                break
                
            case (.failure, .failure):
                break
                
            case let (.found(feed: retrievedFeed, timestamp: retrievedTimestamp),
                      .found(feed: expectedFeed, timestamp: expectedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp)
                
            default:
                XCTFail("Expected to retrieve \(expectedReuslt), got \(retrievalResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
}
