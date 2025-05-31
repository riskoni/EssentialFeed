//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 1.06.25.
//


public struct FeedErrorViewModel {
    public let message: String?
 
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}