//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 1.06.25.
//


public struct ResourceErrorViewModel {
    public let message: String?
 
    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
