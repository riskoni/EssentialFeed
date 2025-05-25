//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Nikolay Riskov on 25.05.25.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    public lazy var view = loadView()
    
    private let loadFeed: ()->Void
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
            
    @objc func refresh() {
        loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
