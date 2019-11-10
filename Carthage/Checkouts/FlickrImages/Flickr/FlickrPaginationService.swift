//
//  FlickrPaginationService.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

public protocol FlickrPaginationServiceProtocol: class {
    
    var delegate: FlickrPaginationServiceDelegate? { get set }
    
    func loadFirstPage(by searchString: String)
    func loadNextPage() -> Bool
}

public protocol FlickrPaginationServiceDelegate: class {
    
    func flickrPaginationService(_ service: FlickrPaginationServiceProtocol,
                                 didLoad images: [FlickrImage],
                                 on page: Int,
                                 by searchString: String)
}

class FlickrPaginationService: FlickrPaginationServiceProtocol {
    
    weak var delegate: FlickrPaginationServiceDelegate?
    
    var pageSize: Int
    
    private(set) var isLoadingNextPage = false
    private(set) var nextPage = 1
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
        
        let page = nextPage
        nextPage += 1
        
        flickrService.loadImageList(searchString: searchString,
                                    perPage: pageSize,
                                    page: page) { [searchString, flickrService] in
            flickrService.loadUIImages(for: $0,
                                       page: page,
                                       completion: { [weak self] in
                guard let self = self else { return }
                self.isLoadingNextPage = false
                self.delegate?.flickrPaginationService(self,
                                                       didLoad: $0,
                                                       on: page,
                                                       by: searchString)
            })
        }
        return true
    }
}
