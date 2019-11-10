//
//  FlickrService.swift
//  UrlSessionLesson
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

protocol FlickrServiceProtocol {

    func loadImage(at path: String, completion: @escaping (UIImage?) -> Void)
    func loadImageList(searchString: String,
                       perPage: Int,
                       page: Int,
                       completion: @escaping ([FlickrImage]) -> Void)
}

class FlickrService: FlickrServiceProtocol {

    let networkService = NetworkService(session: URLSession(configuration: .default))
    
    func loadImage(at path: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: path) else {
            completion(nil)
            return
        }
        networkService.getData(at: url) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
    }

    func loadImageList(searchString: String,
                       perPage: Int,
                       page: Int,
                       completion: @escaping ([FlickrImage]) -> Void) {
        let url = API.searchPath(text: searchString, perPage: perPage, page: page)
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

            let models = photosArray.map { (object) -> FlickrImage in
                let urlString = object["url_m"] as? String ?? ""
                let title = object["title"] as? String ?? ""
                return FlickrImage(path: urlString, description: title, uiImage: nil)
            }
            completion(models)
        }
    }
}
