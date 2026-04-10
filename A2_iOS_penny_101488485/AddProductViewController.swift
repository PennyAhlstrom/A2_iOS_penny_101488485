//
//  AddProductViewController.swift
//  A2_iOS_penny_101488485
//
//  Created by Penny Ahlstrom on 2026-04-09.
//

import UIKit
import CoreData

final class AddProductViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var providerTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var stockQtyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Product"

        priceTextField.keyboardType = .decimalPad
        stockQtyTextField.keyboardType = .numberPad

        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.cornerRadius = 8
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(message: "Enter a product name.")
            return
        }

        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if description.isEmpty {
            showAlert(message: "Enter a product description.")
            return
        }

        guard let priceText = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let price = Decimal(string: priceText) else {
            showAlert(message: "Enter a valid price.")
            return
        }

        guard let provider = providerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !provider.isEmpty else {
            showAlert(message: "Enter a provider.")
            return
        }

        let category = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard let stockText = stockQtyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let stockQty = Int32(stockText) else {
            showAlert(message: "Enter a valid stock quantity.")
            return
        }

        let saved = ProductRepository.shared.addProduct(
            name: name,
            description: description,
            price: price,
            provider: provider,
            category: category,
            stockQty: stockQty
        )

        if saved {
            NotificationCenter.default.post(name: .productDataChanged, object: nil)
            dismiss(animated: true)
        } else {
            showAlert(message: "Unable to save product.")
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
