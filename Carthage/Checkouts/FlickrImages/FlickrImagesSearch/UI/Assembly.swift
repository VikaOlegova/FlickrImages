//
//  Assembly.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit
import Flickr

class Assembly {
    
    func createModule() -> UIViewController {
        let flickrPaginationService = Flickr.createPaginationService(pageSize: 20)
        
        let presenter = Presenter(flickrService: flickrPaginationService)
        let viewController = ViewController(presenter: presenter)
        presenter.view = viewController
        
        flickrPaginationService.delegate = presenter
        
        return viewController
    }
}
