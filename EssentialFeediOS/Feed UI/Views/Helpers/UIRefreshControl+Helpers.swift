//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Nikolay Riskov on 31.05.25.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
