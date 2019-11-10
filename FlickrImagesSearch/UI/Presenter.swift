//
//  Presenter.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

protocol PresenterInput {
    
    func loadFirstPage(searchString: String)
    func loadNextPage()
}

protocol PresenterOutput: class {
    
    func show(images: [ImageViewModel], firstPage: Bool)
}

class Presenter: PresenterInput {
    
    weak var view: PresenterOutput?
    
    var pageSize: Int
    
    private(set) var images = [ImageViewModel]()
    private(set) var searchString = ""
    
    private let flickrService: FlickrPaginationServiceProtocol
    
    init(flickrService: FlickrPaginationServiceProtocol, pageSize: Int = 20) {
        self.flickrService = flickrService
        self.pageSize = pageSize
    }
    
    func loadFirstPage(searchString: String) {
        self.searchString = searchString
        flickrService.loadFirstPage(by: searchString)
    }
    
    func loadNextPage() {
        _ = flickrService.loadNextPage()
    }
}

extension Presenter: FlickrPaginationServiceDelegate {
    func flickrPaginationService(_ service: FlickrPaginationServiceProtocol,
                                 didLoad images: [FlickrImage],
                                 on page: Int,
                                 by searchString: String) {
        guard searchString == self.searchString else {
            return
        }
        let viewModels: [ImageViewModel] = images.compactMap {
            guard let uiImage = $0.uiImage else { return nil }
            return ImageViewModel(description: $0.description, image: uiImage)
        }
        view?.show(images: viewModels, firstPage: page == 1)
    }
}
