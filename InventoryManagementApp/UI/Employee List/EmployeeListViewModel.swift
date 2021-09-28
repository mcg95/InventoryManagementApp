//
//  EmployeeListViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan on 27/09/2021.
//

import UIKit
import CoreData
import Combine

class EmployeeListViewModel: NSObject {
    
    override init() {
        super.init()
        
        fetchEmployees()
        
        searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { text in
                text.isEmpty ?
                self.fetchEmployees() :
                self.fetchEmployees(withName: text)
            }
            .store(in: &cancellables)
    }
    
    func fetchEmployees(withName name: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ManagementEntity> = ManagementEntity.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "name contains %@", name)
        }
        //3
        do {
            let employeeEntity = try managedContext.fetch(fetchRequest)
            let employees = employeeEntity.map({ Employee(employeeEntity: $0) })
            items.send(employees)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveEmployee(name: String, username: String, password: String, role: UserRole) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let item = Employee(id: UUID(), name: name, username: username, password: password, role: role.rawValue)
        let employee = ManagementEntity(context: managedContext)
        employee.id = item.id
        employee.name = item.name
        employee.username = item.username
        employee.password = item.password
        employee.role = item.role
        
        // 4
        do {
            try managedContext.save()
            items.value.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateEmployee(employee: Employee) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ManagementEntity> = ManagementEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", employee.id.uuidString)
        
        do {
            let employeeEntity = try managedContext.fetch(fetchRequest)
            if let matchedProduct = employeeEntity.first {
                matchedProduct.name = employee.name
                matchedProduct.username = employee.username
                matchedProduct.password = employee.password
                matchedProduct.role = employee.role
                if let index = items.value.firstIndex(where: { $0.id == employee.id }) {
                    items.value[index] = Employee(employeeEntity: matchedProduct)
                }
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteEmployee(withId id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ManagementEntity> = ManagementEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id)
        
        do {
            let employeeEntity = try managedContext.fetch(fetchRequest)
            employeeEntity.forEach({ managedContext.delete($0) })
            try managedContext.save()
            items.value.removeAll(where: { $0.id.uuidString == id })
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    var searchText = CurrentValueSubject<String, Never>("")
    
    private(set) var items = CurrentValueSubject<[Employee], Never>([])
        
    private var cancellables = Set<AnyCancellable>()
}

struct Employee: Hashable {
    init(id: UUID, name: String, username: String, password: String, role: String) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
        self.role = role
    }
    
    init(employeeEntity: ManagementEntity) {
        self.id = employeeEntity.id!
        self.name = employeeEntity.name!
        self.username = employeeEntity.username!
        self.password = employeeEntity.password!
        self.role = employeeEntity.role!
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
    
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.id == rhs.id
    }
}

enum UserRole: String {
    case customer
    case admin
    case employee
}
