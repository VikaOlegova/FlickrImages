//
//  NetworkService.swift
//  FlickrImagesSearch
//
//  Created by Вика on 06/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

protocol NetworkServiceInput {
    
	func getData(at path: URL, completion: @escaping (Data?) -> Void)
    func loadImage(at path: URL, completion: @escaping (UIImage?) -> Void)
}

class NetworkService: NetworkServiceInput {
    
	let session: URLSession

	init(session: URLSession = URLSession(configuration: .default)) {
		self.session = session
	}

	func getData(at path: URL, completion: @escaping (Data?) -> Void) {
		let dataTask = session.dataTask(with: path) { data, _, _ in
			completion(data)
		}
		dataTask.resume()
	}
    
    func loadImage(at path: URL, completion: @escaping (UIImage?) -> Void) {
        getData(at: path) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
    }
}
