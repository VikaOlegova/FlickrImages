//
//  FlickrPaginationService.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

protocol FlickrPaginationServiceProtocol {
    
    func loadFirstPage(by searchString: String)
    func loadNextPage() -> Bool
}

protocol FlickrPaginationServiceDelegate: class {
    
    func flickrPaginationService(_ service: FlickrPaginationServiceProtocol,
                                 didLoad images: [FlickrImage],
                                 on page: Int)
}

class FlickrPaginationService: FlickrPaginationServiceProtocol {
    
    weak var delegate: FlickrPaginationServiceDelegate?
    
    var pageSize: Int
    
    private(set) var isLoadingNextPage = false
    private(set) var nextPage = 1
    private(set) var images = [FlickrImage]()
    private(set) var searchString: String? = nil
    
    private let flickrService: FlickrServiceProtocol
    
    init(flickrService: FlickrServiceProtocol, pageSize: Int = 20) {
        self.flickrService = flickrService
        self.pageSize = pageSize
    }
    
    func loadFirstPage(by searchString: String) {
        self.nextPage = 1
        self.searchString = searchString
        _ = loadNextPage()
    }
    
    func loadNextPage() -> Bool {
        guard
            let searchString = searchString,
            nextPage == 1 || !isLoadingNextPage
            else { return false }
        
        isLoadingNextPage = true
        
        flickrService.loadImageList(searchString: searchString,
                                    perPage: pageSize,
                                    page: nextPage) { [page = nextPage, flickrService] in
            flickrService.loadUIImages(for: $0,
                                       page: page,
                                       completion: { [weak self] in
                guard let self = self else { return }
                self.delegate?.flickrPaginationService(self, didLoad: $0, on: page)
            })
        }
        return true
    }
}
