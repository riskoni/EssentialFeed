//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Nikolay Riskov on 7.06.25.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() throws {
        try makeSUT { sut, imageDataURL in
            self.expect(sut, toCompleteRetrievalWith: self.notFound(), for: anyURL())
        }
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws {
        try makeSUT { sut, imageDataURL in
            let nonMatchingURL = URL(string: "http://another-url.com")!
            self.expect(sut, toCompleteRetrievalWith: self.notFound(), for: nonMatchingURL)
        }
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws {
        try makeSUT { sut, imageDataURL in
            let storedData = anyData()
            
            self.insert(storedData, for: imageDataURL, into: sut)
            
            self.expect(sut, toCompleteRetrievalWith: self.found(storedData), for: imageDataURL)
        }
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() throws {
        try makeSUT { sut, imageDataURL in
            let firstStoredData = Data("first".utf8)
            let lastStoredData = Data("last".utf8)
            
            self.insert(firstStoredData, for: imageDataURL, into: sut)
            self.insert(lastStoredData, for: imageDataURL, into: sut)
            
            self.expect(sut, toCompleteRetrievalWith: self.found(lastStoredData), for: imageDataURL)
        }
    }
    
    // - MARK: Helpers
    
    private func makeSUT(_ test: @escaping (CoreDataFeedStore, URL) -> Void, file: StaticString = #filePath, line: UInt = #line) throws {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        let exp = expectation(description: "wait for operation")
        sut.perform {
            let imageDataURL = URL(string: "http://a-url.com")!
            self.insertFeedImage(with: imageDataURL, into: sut, file: file, line: line)
            test(sut, imageDataURL)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    private func notFound() -> Result<Data?, Error> {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> Result<Data?, Error> {
        return .success(data)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func expect(_ sut: FeedImageDataStore, toCompleteRetrievalWith expectedResult: Result<Data?, Error>, for url: URL,  file: StaticString = #filePath, line: UInt = #line) {
        let receivedResult = Result { try sut.retrieve(dataForURL: url) }

        switch (receivedResult, expectedResult) {
        case let (.success( receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    func insert(_ data: Data, for url: URL, into sut: FeedImageDataStore, file: StaticString = #filePath, line: UInt = #line) {
        do {
            try sut.insert(data, for: url)
        } catch {
            XCTFail("Failed to insert image data: \(data) - error: \(error)", file: file, line: line)
        }
    }
    
    private func insertFeedImage(with url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        do {
            let image = LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
            try sut.insert([image], timestamp: Date())
        } catch {
            XCTFail("Failed to insert feed image with URL \(url) - error: \(error)", file: file, line: line)
        }
    }
    
}
