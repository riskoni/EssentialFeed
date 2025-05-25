//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Nikolay Riskov on 25.05.25.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
