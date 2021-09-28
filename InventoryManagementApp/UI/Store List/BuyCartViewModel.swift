//
//  BuyCartViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Combine
import UIKit
import CoreData

class BuyCartViewModel: NSObject {
    
    override init() {
        super.init()
        
        fetchCarts()
        
        searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { text in
                text.isEmpty ?
                self.fetchCarts() :
                self.fetchCarts(withName: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchCarts(withName name: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<CartEntity> = CartEntity.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "productName contains[c] %@", name)
        }
        //3
        do {
            let cartEntity = try managedContext.fetch(fetchRequest)
            let carts = cartEntity.map({ BuyCart(cartEntity: $0) })
            items.send(carts)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deleteCartItem(withId id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<CartEntity> = CartEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id)
        
        do {
            let cartEntity = try managedContext.fetch(fetchRequest)
            cartEntity.forEach({ managedContext.delete($0) })
            try managedContext.save()
            items.value.removeAll(where: { $0.id.uuidString == id })
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func saveOrder() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        for item in items.value {
            let orderEntity = OrderEntity(context: managedContext)
            orderEntity.id = UUID()
            orderEntity.productId = UUID(uuidString: item.productId)
            orderEntity.price = item.price
            orderEntity.quantity = item.quantity
            
            deleteCartItem(withId: item.id.uuidString)
        }
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    var searchText = CurrentValueSubject<String, Never>("")
    
    private(set) var items = CurrentValueSubject<[BuyCart], Never>([])
        
    private var cancellables = Set<AnyCancellable>()
}
