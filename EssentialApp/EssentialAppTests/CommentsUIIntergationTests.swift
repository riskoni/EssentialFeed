//
//  CommentsUIIntergationTests.swift
//  EssentialAppTests
//
//  Created by Nikolay Riskov on 10.07.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import Combine
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class CommentsUIIntergationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before the view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once the view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request on user refresh action")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected third loading request on user refresh action")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected no further loading requests once the view re-appears")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user performs a refresh action")

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated loading completes with error")
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected loading indicator to stay hidden on view re-appearance")
    }
    
    func test_loadCommentsCompletion_rendersSucessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())

        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }
    
    func test_loadCommentCompletion_doesNotAlterCurrentRenderintStateOnError() {
        let comment = makeComment(message: "a description", username: "a location")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        
        var sut: ListViewController?
        
        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            })
            
            sut?.loadViewIfNeeded()
        }
        
        XCTAssertEqual(cancelCallCount, 0)
        
        sut = nil
        
        XCTAssertEqual(cancelCallCount, 1)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeComment(message: String = "any message", username: String = "any username", url: URL = URL(string: "http://any-url.com")!) -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)

        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()
        
        var loadCommentsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
            requests[index].send(completion: .finished)
        }
        
        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
    
}


