//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 29.06.25.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>
                                                    
public extension RemoteImageCommentsLoader {
    
    convenience init(url: URL, client: HTTPClient){
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
