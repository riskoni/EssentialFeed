//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Nikolay on 31.05.24.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var viewAppeared = false
    
    public convenience init(loader: FeedLoader ) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !viewAppeared {
            viewAppeared = true
            refreshControl?.beginRefreshing()
        }
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
