//
//  FlickrService.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import Foundation

protocol FlickrServiceProtocol {

    func loadImageList(searchString: String,
                       perPage: Int,
                       page: Int,
                       completion: @escaping ([FlickrImage]) -> Void)
    
    func loadUIImages(for images: [FlickrImage],
                      page: Int,
                      completion: @escaping ([FlickrImage]) -> Void)
}

class FlickrService: FlickrServiceProtocol {

    let networkService: NetworkServiceInput
    
    init(networkService: NetworkServiceInput) {
        self.networkService = networkService
    }

    func loadImageList(searchString: String,
                       perPage: Int,
                       page: Int,
                       completion: @escaping ([FlickrImage]) -> Void) {
        let url = FlickrAPI.searchPath(text: searchString, perPage: perPage, page: page)
        networkService.getData(at: url) { data in
            guard let data = data else {
                completion([])
                return
            }
            let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: .init()) as? Dictionary<String, Any>

            guard let response = responseDictionary,
                let photosDictionary = response["photos"] as? Dictionary<String, Any>,
                let photosArray = photosDictionary["photo"] as? [[String: Any]] else {
                    completion([])
                    return
            }

            let models = photosArray.compactMap { (object) -> FlickrImage? in
                guard
                    let urlString = object["url_m"] as? String,
                    let url = URL(string: urlString)
                    else { return nil }
                
                let title = object["title"] as? String ?? ""
                
                return FlickrImage(path: url, description: title, uiImage: nil)
            }
            completion(models)
        }
    }
    
    func loadUIImages(for images: [FlickrImage],
                      page: Int,
                      completion: @escaping ([FlickrImage]) -> Void) {
        let group = DispatchGroup()
        var newImages: [FlickrImage] = []
        for model in images {
            group.enter()
            networkService.loadImage(at: model.path) { [weak self] image in
                defer { group.leave() }
                guard let image = image else { return }
                
                newImages.append(model.with(uiImage: image))
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(newImages)
        }
    }
}
