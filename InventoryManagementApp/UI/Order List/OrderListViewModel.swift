//
//  OrderListViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import UIKit
import Combine
import CoreData

class OrderListViewModel: NSObject {
    
    override init() {
        super.init()
        
        fetchOrders()
        
        searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { text in
                text.isEmpty ?
                self.fetchOrders() :
                self.fetchOrders(withName: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchOrders(withName name: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let orderFetchRequest: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        let productFetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        if let name = name {
            productFetchRequest.predicate = NSPredicate(format: "name contains %@", name)
        }
        //3
        do {
            let orderEntity = try managedContext.fetch(orderFetchRequest)
            var orders = orderEntity.map({ Order(orderEntity: $0) })
            let productsEntity = try managedContext.fetch(productFetchRequest)
            let products = productsEntity.map({ Product(productEntity: $0) })
            self.products = products
            for (index, order) in orders.enumerated() {
                let product = products.first(where: { $0.id == order.productId })
                orders[index].product = product
            }
            if let _ = name {
                orders = items.value.filter({
                    guard let product = $0.product else { return false }
                    
                    return products.contains(product)
                })
            }
            items.send(orders)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveOrder(order: Order) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if self.items.value.contains(where: { $0.id == order.id }) {
            updateOrder(order: order)
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let orderEntity = OrderEntity(context: managedContext)
        orderEntity.id = order.id
        orderEntity.productId = order.productId
        orderEntity.price = order.price
        orderEntity.quantity = order.quantity
        
        // 4
        do {
            try managedContext.save()
            items.value.append(order)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateOrder(order: Order) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", order.id.uuidString)
        
        do {
            let orderEntity = try managedContext.fetch(fetchRequest)
            if let matchedProduct = orderEntity.first {
                matchedProduct.price = order.price
                matchedProduct.quantity = order.quantity
                if let index = items.value.firstIndex(where: { $0.id == order.id }) {
                    items.value[index] = Order(orderEntity: matchedProduct)
                }
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteOrder(withId id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id)
        
        do {
            let orderEntity = try managedContext.fetch(fetchRequest)
            orderEntity.forEach({ managedContext.delete($0) })
            try managedContext.save()
            items.value.removeAll(where: { $0.id.uuidString == id })
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    var searchText = CurrentValueSubject<String, Never>("")
    
    private(set) var items = CurrentValueSubject<[Order], Never>([])
    
    var products: [Product] = [Product]()
    
    private var cancellables = Set<AnyCancellable>()
}

struct Order: Hashable {
    init(id: UUID, productId: UUID, price: Double, quantity: Int64, product: Product) {
        self.id = id
        self.productId = productId
        self.price = price
        self.quantity = quantity
        self.product = product
    }
    
    init(orderEntity: OrderEntity) {
        self.id = orderEntity.id!
        self.productId = orderEntity.productId!
        self.quantity = orderEntity.quantity
        self.price = orderEntity.price
    }
    
    var id: UUID
    var productId: UUID
    var price: Double
    var quantity: Int64
    var product: Product?
    
    //----------------------------------------
    // MARK:- Hashable protocols
    //----------------------------------------
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id
    }
}
