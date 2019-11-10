//
//  FlickrImage.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

public struct FlickrImage {
    public let path: URL
    public let description: String
    public let uiImage: UIImage?
    
    public func with(uiImage: UIImage) -> FlickrImage {
        return FlickrImage(path: path,
                           description: description,
                           uiImage: uiImage)
    }
}
