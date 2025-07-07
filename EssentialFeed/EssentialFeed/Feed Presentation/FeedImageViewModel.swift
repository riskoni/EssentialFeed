//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 1.06.25.
//
import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
