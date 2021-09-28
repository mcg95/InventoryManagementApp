//
//  SignInViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import UIKit
import CoreData
import Combine

class SignInViewModel: NSObject {
    //----------------------------------------
    // MARK:- Initialization
    //----------------------------------------
    
    override init() {
        super.init()
        
        fetchEmployees()
        fetchCustomers()
    }
    
    //----------------------------------------
    // MARK:- Core Data Methods
    //----------------------------------------
    
    func fetchEmployees() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<ManagementEntity> = ManagementEntity.fetchRequest()
        //3
        do {
            let employeeEntity = try managedContext.fetch(fetchRequest)
            let employees = employeeEntity.map({
                User(username: $0.username!,
                     password: $0.password!,
                     role: UserRole(rawValue: $0.role!)!)
                
            })
            items.value.append(contentsOf: employees)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchCustomers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest: NSFetchRequest<CustomerEntity> = CustomerEntity.fetchRequest()
        //3
        do {
            let customerEntity = try managedContext.fetch(fetchRequest)
            let customers = customerEntity.map({ entity in
                User(username: entity.username!,
                     password: entity.password!,
                     role: UserRole(rawValue: entity.role!)!)
            })
            items.value.append(contentsOf: customers)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //----------------------------------------
    // MARK:- Login
    //----------------------------------------
    
    func performLogin() {
        guard let loginParams = loginParams else { return }
        
        let matchingCredentials = items.value.filter({
            $0.username.lowercased() == loginParams.username?.lowercased() &&
            $0.password == loginParams.password
        })
        
        isLoginSuccess.send((!matchingCredentials.isEmpty, matchingCredentials.first?.role))
    }
        
    //----------------------------------------
    // MARK:- Properties
    //----------------------------------------
    
    var isLoginSuccess = CurrentValueSubject<(Bool, UserRole?), Never>((false, nil))

    private(set) var items = CurrentValueSubject<[User], Never>([])

    var loginParams: SignInParams?
}

struct User {
    let username: String
    let password: String
    let role: UserRole
}
