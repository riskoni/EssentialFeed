//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 8.07.25.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Title for the comments view")
    }

}
