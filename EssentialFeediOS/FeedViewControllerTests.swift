//
//  FeedViewControllerTests.swift
//  EssentialFeediOS
//
//  Created by Nikolay on 30.05.24.
//

import XCTest
import UIKit

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy ) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    //MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
    
}
