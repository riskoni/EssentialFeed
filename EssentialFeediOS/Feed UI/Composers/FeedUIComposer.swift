//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 25.05.25.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader? ) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map{
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
