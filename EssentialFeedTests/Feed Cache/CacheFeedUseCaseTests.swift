//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Nikolay on 21.05.24.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    
    init(store: FeedStore, currentDate: @escaping ()->Date){
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?)->Void) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insertItems(items, timestamp: self.currentDate(), completion: completion)
            }else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void

    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageTheStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completInsertion(with: insertionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }

    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping ()->Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
