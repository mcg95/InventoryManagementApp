//
//  StoreListViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import UIKit
import CoreData
import Combine

class StoreListViewModel: NSObject {
    
    override init() {
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
    
    func saveToCart(productId: String, name: String, price: Double, quantity: Int64) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let item = BuyCart(id: UUID(), productId: productId, productName: name, price: price, quantity: quantity)
        let cart = CartEntity(context: managedContext)
        cart.id = item.id
        cart.productId = item.productId
        cart.productName = item.productName
        cart.price = item.price
        cart.quantity = item.quantity
        cart.totalPrice = item.totalPrice
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateCart(product: Product) {
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
    
    func deleteCart(withId id: String) {
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
        
    private var cancellables = Set<AnyCancellable>()
}

struct BuyCart: Hashable {
    init(id: UUID, productId: String, productName: String, price: Double, quantity: Int64) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        self.price = price
        self.totalPrice = price * Double(quantity)
    }
    
    init(cartEntity: CartEntity) {
        self.id = cartEntity.id!
        self.productId = cartEntity.productId!
        self.productName = cartEntity.productName!
        self.quantity = cartEntity.quantity
        self.price = cartEntity.price
        self.totalPrice = cartEntity.price * Double(cartEntity.quantity)
    }
    
    var id: UUID
    var productId: String
    var productName: String
    var price: Double
    var quantity: Int64
    var totalPrice: Double
    
    //----------------------------------------
    // MARK:- Hashable protocols
    //----------------------------------------
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BuyCart, rhs: BuyCart) -> Bool {
        lhs.id == rhs.id
    }
}
