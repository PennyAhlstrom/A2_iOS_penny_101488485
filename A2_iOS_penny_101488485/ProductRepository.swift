//
//  ProductRepository.swift
//  A2_iOS_penny_101488485
//
//  Created by Penny Ahlstrom on 2026-04-09.
//

import UIKit
import CoreData

final class ProductRepository {
    static let shared = ProductRepository()
    private init() {}

    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    func fetchAllProducts() -> [ProductEntity] {
        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "productName", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Fetch all products failed: \(error)")
            return []
        }
    }

    func searchProducts(keyword: String) -> [ProductEntity] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return fetchAllProducts() }

        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "productName", ascending: true)]
        request.predicate = NSPredicate(
            format: "productName CONTAINS[cd] %@ OR productDescription CONTAINS[cd] %@",
            trimmed, trimmed
        )

        do {
            return try context.fetch(request)
        } catch {
            print("Search failed: \(error)")
            return []
        }
    }

    func addProduct(
        name: String,
        description: String,
        price: Decimal,
        provider: String,
        category: String,
        stockQty: Int32
    ) -> Bool {
        let product = ProductEntity(context: context)
        product.productId = UUID()
        product.productName = name
        product.productDescription = description
        product.productPrice = NSDecimalNumber(decimal: price)
        product.productProvider = provider
        product.productCategory = category
        product.productStockQty = Int32(stockQty)

        return saveContext()
    }

    func seedProductsIfNeeded() {
        let existing = fetchAllProducts()
        if !existing.isEmpty { return }

        let sampleProducts: [(String, String, Decimal, String, String, Int32)] = [
            ("iPhone Case", "Shockproof silicone case for iPhone 15.", 24.99, "Apple Accessories Inc.", "Accessories", 40),
            ("Wireless Mouse", "Ergonomic Bluetooth mouse for daily use.", 34.50, "LogiTech Supplies", "Electronics", 25),
            ("Laptop Stand", "Adjustable aluminum stand for laptops up to 17 inches.", 49.99, "Office Pro", "Office", 18),
            ("USB-C Cable", "Fast charging braided USB-C cable, 2 meters.", 14.99, "CableHub", "Electronics", 60),
            ("Notebook Set", "Pack of 3 hardcover notebooks for school and work.", 19.99, "PaperLine", "Stationery", 32),
            ("Desk Lamp", "LED desk lamp with adjustable brightness.", 39.95, "BrightHome", "Home", 14),
            ("Water Bottle", "Insulated stainless steel bottle, 750 ml.", 22.75, "HydroMax", "Lifestyle", 28),
            ("Backpack", "Durable backpack with laptop compartment.", 59.99, "UrbanCarry", "Bags", 12),
            ("Keyboard", "Compact wireless keyboard with rechargeable battery.", 54.99, "KeyWorks", "Electronics", 20),
            ("Headphones", "Noise-isolating over-ear headphones.", 79.99, "SoundPeak", "Electronics", 10)
        ]

        for item in sampleProducts {
            _ = addProduct(
                name: item.0,
                description: item.1,
                price: item.2,
                provider: item.3,
                category: item.4,
                stockQty: item.5
            )
        }
    }

    @discardableResult
    private func saveContext() -> Bool {
        if !context.hasChanges { return true }

        do {
            try context.save()
            return true
        } catch {
            print("Save failed: \(error)")
            return false
        }
    }
}

extension Notification.Name {
    static let productDataChanged = Notification.Name("productDataChanged")
}
