//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.07.25.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Hashable {
    public let message: String
    public let date: String
    public let username: String

    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Title for the comments view")
    }
    
    public static func map(
            _ comments: [ImageComment],
            currentDate: Date = Date(),
            calendar: Calendar = .current,
            locale: Locale = .current
        ) -> ImageCommentsViewModel
    {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        
        return ImageCommentsViewModel(comments: comments.map { comment in
            ImageCommentViewModel(
                message: comment.message,
                date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
                username: comment.username)
        })
    }

}
