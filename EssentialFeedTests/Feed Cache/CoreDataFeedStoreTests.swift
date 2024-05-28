//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Nikolay on 25.05.24.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()

        let sut = makeSUT()

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()

        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()

        let sut = makeSUT()
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()

        let sut = makeSUT()

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        let sut = makeSUT()

        insert((feed.local, timestamp), to: sut)

        stub.startIntercepting()

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let sut = makeSUT()

        insert((feed, timestamp), to: sut)

        stub.startIntercepting()

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)))
    }

    func test_delete_removesAllObjects() {
        let store = makeSUT()

        insert((uniqueImageFeed().local, Date()), to: store)

        deleteCache(from: store)

        let context = try! NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: XCTUnwrap(CoreDataFeedStore.model),
            url: inMemoryStoreURL()
        ).viewContext

        let existingObjects = try! context.allExistingObjects()

        XCTAssertEqual(existingObjects, [], "found orphaned objects in Core Data")
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        assertThatSideEffectsRunSerially(on: sut)
    }

    func test_imageEntity_properties() {
        let entity = try! XCTUnwrap( CoreDataFeedStore.model?.entitiesByName["FeedImageEntity"] )

        entity.verify(attribute: "id", hasType: .UUIDAttributeType, isOptional: false)
        entity.verify(attribute: "descriptionText", hasType: .stringAttributeType, isOptional: true)
        entity.verify(attribute: "location", hasType: .stringAttributeType, isOptional: true)
        entity.verify(attribute: "url", hasType: .URIAttributeType, isOptional: false)
    }

    // - MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = try! CoreDataFeedStore(storeURL: inMemoryStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func inMemoryStoreURL() -> URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }
}

extension CoreDataFeedStore.ModelNotFound: CustomStringConvertible {
    public var description: String {
        "Core Data Model '\(modelName).xcdatamodeld' not found. You need to create it in the production target."
    }
}
