//
//  FlickrPaginationService.swift
//  UrlSessionLesson
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

struct FlickrImage {
    let path: String
    let description: String
    let uiImage: UIImage?
    
    func with(uiImage: UIImage) -> FlickrImage {
        return FlickrImage(path: path,
                           description: description,
                           uiImage: uiImage)
    }
}

protocol FlickrPaginationServiceProtocol {
    func loadFirstPage(by searchString: String)
    func loadNextPage() -> Bool
}

protocol FlickrPaginationServiceDelegate: class {
    func flickrPaginationService(_ service: FlickrPaginationServiceProtocol,
                                 didLoad images: [FlickrImage],
                                 page: Int)
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
                                    page: nextPage) { [weak self, nextPage] images in
                                        self?.loadUIImages(for: images, page: nextPage)
        }
        
        return true
    }
    
    private func loadUIImages(for images: [FlickrImage], page: Int) {
        let group = DispatchGroup()
        var newImages: [FlickrImage] = []
        for model in images {
            group.enter()
            flickrService.loadImage(at: model.path) { [weak self] image in
                defer {
                    group.leave()
                }
                guard let image = image else {
                    print("Image not loaded")
                    return
                }
                let result = model.with(uiImage: image)
                newImages.append(result)
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.nextPage = page + 1
            self.delegate?.flickrPaginationService(self, didLoad: newImages, page: page)
            self.isLoadingNextPage = false
        }
    }
}
