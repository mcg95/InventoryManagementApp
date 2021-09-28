//
//  AppDelegate.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = .systemIndigo
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = .systemIndigo
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        if !userDefaults.bool(forKey: "hasCreatedData") {
            createInitialUsers()
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "InventoryManagementApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createInitialUsers() {
        // 1
        let managedContext = self.persistentContainer.viewContext
        
        // 2
        let adminItem = Employee(id: UUID(), name: "Administrator", username: "Admin", password: "12345678", role: UserRole.admin.rawValue)
        let employeeItem = Employee(id: UUID(), name: "Manager", username: "Manager", password: "12345678", role: UserRole.employee.rawValue)
        let customerItem = Customer(id: UUID(), name: "John Doe", username: "johndoe", password: "12345678", role: UserRole.customer.rawValue)
        
        let admin = ManagementEntity(context: managedContext)
        admin.id = adminItem.id
        admin.name = adminItem.name
        admin.username = adminItem.username
        admin.password = adminItem.password
        admin.role = adminItem.role
        
        let employee = ManagementEntity(context: managedContext)
        employee.id = employeeItem.id
        employee.name = employeeItem.name
        employee.username = employeeItem.username
        employee.password = employeeItem.password
        employee.role = employeeItem.role
        
        let customer = CustomerEntity(context: managedContext)
        customer.id = customerItem.id
        customer.name = customerItem.name
        customer.username = customerItem.username
        customer.password = customerItem.password
        customer.role = customerItem.role
        // 4
        
        do {
            try managedContext.save()
            userDefaults.set(true, forKey: "hasCreatedData")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

