//
//  FeedViewControllerTests.swift
//  EssentialFeediOS
//
//  Created by Nikolay on 30.05.24.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before the view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once the view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request on user refresh action")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected third loading request on user refresh action")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected no further loading requests once the view re-appears")
    }

    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user performs a refresh action")

        loader.completeFeedLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated loading is completed")
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected loading indicator to stay hidden on view re-appearance")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var loadCompletions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            return loadCompletions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCompletions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            loadCompletions[index](.success([]))
        }
    }
}

private extension UITableViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        refreshControl?.allTargets.forEach{ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{ action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool {
        return _isRefreshing
    }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
