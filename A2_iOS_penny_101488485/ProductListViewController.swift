//
//  ProductListViewController.swift
//  A2_iOS_penny_101488485
//
//  Created by Penny Ahlstrom on 2026-04-09.
//

import UIKit
import CoreData

final class ProductListViewController: UITableViewController, UISearchResultsUpdating {

    private var products: [ProductEntity] = []
    private var filteredProducts: [ProductEntity] = []

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "All Products"

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search name or description"

        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }

    private func loadProducts() {
        products = ProductRepository.shared.fetchAllProducts()
        filteredProducts = products
        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        filteredProducts = ProductRepository.shared.searchProducts(keyword: text)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = filteredProducts[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = product.productName ?? "-"
        content.secondaryText = product.productDescription ?? "-"
        content.secondaryTextProperties.numberOfLines = 2

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = filteredProducts[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        detailVC.selectedProductID = product.objectID

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
