//
//  ProductDetailViewController.swift
//  A2_iOS_penny_101488485
//
//  Created by Penny Ahlstrom on 2026-04-09.
//

import UIKit
import CoreData

final class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productProviderLabel: UILabel!
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var productStockLabel: UILabel!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var selectedProductID: NSManagedObjectID?

    private var products: [ProductEntity] = []
    private var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Product Details"
        productDescriptionLabel.numberOfLines = 0

        ProductRepository.shared.seedProductsIfNeeded()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProductDataChanged),
            name: .productDataChanged,
            object: nil
        )

        loadProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleProductDataChanged() {
        loadProducts()
    }

    private func loadProducts() {
        products = ProductRepository.shared.fetchAllProducts()
        
        print("Loaded products count: \(products.count)")
        print("Current index: \(currentIndex)")
        
        guard !products.isEmpty else {
            clearLabels()
            previousButton.isEnabled = false
            nextButton.isEnabled = false
            return
        }

        if let selectedProductID = selectedProductID,
           let index = products.firstIndex(where: { $0.objectID == selectedProductID }) {
            currentIndex = index
        } else {
            if currentIndex >= products.count { currentIndex = 0 }
        }

        displayProduct(at: currentIndex)
    }

    private func displayProduct(at index: Int) {
        guard index >= 0, index < products.count else { return }

        let product = products[index]

        productIdLabel.text = product.productId?.uuidString ?? "-"
        productNameLabel.text = product.productName ?? "-"
        productDescriptionLabel.text = product.productDescription ?? "-"
        productPriceLabel.text = formattedPrice(product.productPrice)
        productProviderLabel.text = product.productProvider ?? "-"
        productCategoryLabel.text = product.productCategory ?? "-"
        productStockLabel.text = product.productStockQty == 0 ? "Out of Stock" : "\(product.productStockQty)"

        updateNavigationButtons()
    }

    private func updateNavigationButtons() {
        previousButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < products.count - 1
    }

    private func clearLabels() {
        productIdLabel.text = "-"
        productNameLabel.text = "No products available"
        productDescriptionLabel.text = "-"
        productPriceLabel.text = "-"
        productProviderLabel.text = "-"
        productCategoryLabel.text = "-"
        productStockLabel.text = "-"
    }

    private func formattedPrice(_ price: NSDecimalNumber?) -> String {
        guard let price = price else { return "-" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: price) ?? "$0.00"
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        print("Previous tapped")
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        displayProduct(at: currentIndex)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        print("Next tapped")
            guard currentIndex < products.count - 1 else { return }
            currentIndex += 1
            displayProduct(at: currentIndex)
    }
}
