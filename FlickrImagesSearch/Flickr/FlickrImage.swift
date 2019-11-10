//
//  FlickrImage.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

struct FlickrImage {
    let path: URL
    let description: String
    let uiImage: UIImage?
    
    func with(uiImage: UIImage) -> FlickrImage {
        return FlickrImage(path: path,
                           description: description,
                           uiImage: uiImage)
    }
}
