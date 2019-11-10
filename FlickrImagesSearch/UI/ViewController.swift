//
//  ViewController.swift
//  FlickrImagesSearch
//
//  Created by Вика on 10/11/2019.
//  Copyright © 2019 Vika Olegova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let tableView = UITableView()
    var images: [ImageViewModel] = []
    let reuseId = "UITableViewCellreuseId"
    let presenter: PresenterInput
    let searchController = UISearchController(searchResultsController: nil)
    
    init(presenter: PresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Метод не реализован")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search images"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchController.searchBar.becomeFirstResponder()
    }
}

extension ViewController: PresenterOutput {
    func show(images: [ImageViewModel], firstPage: Bool) {
        self.images = firstPage ? images : self.images + images
        tableView.reloadData()
    }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults (for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let currentText = searchBar.text!
        if (currentText == "") {
            clearTable()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentText != searchBar.text! {
                return
            }
            self.presenter.loadFirstPage(searchString: currentText)
        }
    }
    
    func clearTable() {
        images.removeAll()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        let model = images[indexPath.row]
        cell.imageView?.image = model.image
        cell.textLabel?.text = model.description
        
        if indexPath.row == images.count - 1 {
            presenter.loadNextPage()
        }
        
        return cell
    }
}
