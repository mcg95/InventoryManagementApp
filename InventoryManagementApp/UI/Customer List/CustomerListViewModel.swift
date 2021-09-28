//
//  CustomerListViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import UIKit
import CoreData
import Combine

class CustomerListViewModel: NSObject {
    
    override init() {
        super.init()
        
        fetchCustomers()
        
        searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { text in
                text.isEmpty ?
                self.fetchCustomers() :
                self.fetchCustomers(withName: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchCustomers(withName name: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "name contains %@", name)
        }
        //3
        do {
            let customerEntity = try managedContext.fetch(fetchRequest)
            let customers = customerEntity.map({ Customer(customerEntity: $0) })
            items.send(customers)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveCustomer(name: String, username: String, password: String, role: UserRole) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let item = Customer(id: UUID(), name: name, username: username, password: password, role: role.rawValue)
        let customer = CustomerEntity(context: managedContext)
        customer.id = item.id
        customer.name = item.name
        customer.username = item.username
        customer.password = item.password
        customer.role = item.role
        
        // 4
        do {
            try managedContext.save()
            items.value.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateCustomer(customer: Customer) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", customer.id.uuidString)
        
        do {
            let customerEntity = try managedContext.fetch(fetchRequest)
            if let matchedProduct = customerEntity.first {
                matchedProduct.name = customer.name
                matchedProduct.username = customer.username
                matchedProduct.password = customer.password
                matchedProduct.role = customer.role
                if let index = items.value.firstIndex(where: { $0.id == customer.id }) {
                    items.value[index] = Customer(customerEntity: matchedProduct)
                }
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteCustomer(withId id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id)
        
        do {
            let customerEntity = try managedContext.fetch(fetchRequest)
            customerEntity.forEach({ managedContext.delete($0) })
            try managedContext.save()
            items.value.removeAll(where: { $0.id.uuidString == id })
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    var searchText = CurrentValueSubject<String, Never>("")
    
    private(set) var items = CurrentValueSubject<[Customer], Never>([])
        
    private var cancellables = Set<AnyCancellable>()
}

struct Customer: Hashable {
    init(id: UUID, name: String, username: String, password: String, role: String) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
        self.role = role
    }
    
    init(customerEntity: CustomerEntity) {
        self.id = customerEntity.id!
        self.name = customerEntity.name!
        self.username = customerEntity.username!
        self.password = customerEntity.password!
        self.role = customerEntity.role!
    }
    
    var id: UUID
    var name: String
    var username: String
    var password: String
    var role: String
    
    //----------------------------------------
    // MARK:- Hashable protocols
    //----------------------------------------
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Customer, rhs: Customer) -> Bool {
        lhs.id == rhs.id
    }
}
