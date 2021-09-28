//
//  ListViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import UIKit
import CoreData
import Combine

class ListViewModel: NSObject {
    
    init(listType: ListType) {
        self.listType = listType
        
        super.init()
        
        fetchProducts()
        
        searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { text in
                text.isEmpty ?
                self.fetchProducts() :
                self.fetchProducts(withName: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchProducts(withName name: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "name contains %@", name)
        }
        //3
        do {
            let productEntity = try managedContext.fetch(fetchRequest)
            let products = productEntity.map({ Product(productEntity: $0) })
            items.send(products)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveProduct(name: String, price: Double) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let item = Product(id: UUID(), name: name, price: price)
        let product = ProductEntity(context: managedContext)
        product.id = item.id
        product.name = item.name
        product.price = item.price
        
        // 4
        do {
            try managedContext.save()
            items.value.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateProduct(product: Product) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", product.id.uuidString)
        
        do {
            let productEntity = try managedContext.fetch(fetchRequest)
            if let matchedProduct = productEntity.first {
                matchedProduct.name = product.name
                matchedProduct.price = product.price
                if let index = items.value.firstIndex(where: { $0.id == product.id }) {
                    items.value[index] = Product(productEntity: matchedProduct)
                }
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteProduct(withId id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id)
        
        do {
            let productEntity = try managedContext.fetch(fetchRequest)
            productEntity.forEach({ managedContext.delete($0) })
            try managedContext.save()
            items.value.removeAll(where: { $0.id.uuidString == id })
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    var searchText = CurrentValueSubject<String, Never>("")
    
    private(set) var items = CurrentValueSubject<[Product], Never>([])

    private(set) var listType: ListType
    
    private var cancellables = Set<AnyCancellable>()
}

struct Product: Hashable {
    init(id: UUID, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
    
    init(productEntity: ProductEntity) {
        self.id = productEntity.id!
        self.name = productEntity.name!
        self.price = productEntity.price
    }
    
    var id: UUID
    var name: String
    var price: Double
    
    //----------------------------------------
    // MARK:- Hashable protocols
    //----------------------------------------
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}
