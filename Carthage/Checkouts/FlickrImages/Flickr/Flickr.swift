//
//  Flickr.swift
//  Flickr
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import Foundation

public class Flickr {
    
    private init() { }
    
    public static func createPaginationService(pageSize: Int) -> FlickrPaginationServiceProtocol {
        let networkService = NetworkService()
        let flickrService = FlickrService(networkService: networkService)
        let flickrPaginationService = FlickrPaginationService(flickrService: flickrService,
                                                              pageSize: pageSize)
        
        return flickrPaginationService
    }
}
