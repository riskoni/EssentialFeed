//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Nikolay Riskov on 25.05.25.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display( FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinsihLoadingFeed(with error: Error) {
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
}
