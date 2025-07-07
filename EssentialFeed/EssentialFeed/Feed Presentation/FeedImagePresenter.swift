//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 2.06.25.
//

import Foundation

public final class FeedImagePresenter {
    
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)           
    }
}
