//
//  FeedViewControllerTests.swift
//  EssentialFeediOS
//
//  Created by Nikolay on 30.05.24.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var viewAppeared = false
    
    convenience init(loader: FeedLoader ) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !viewAppeared {
            viewAppeared = true
            refreshControl?.beginRefreshing()
        }
    }
    
    @objc private func load() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
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
        
        func completeFeedLoading() {
            loadCompletions.last?(.success([]))
        }
    }
}

private extension UITableViewController {

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
