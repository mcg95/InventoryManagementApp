//
//  Managed.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import Foundation
import CoreData

/// Implement this protocol on Core Data model classes to create fetch requests.
protocol Managed: AnyObject, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
}

extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
    static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
    
    static var defaultFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        return request
    }
    
    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        
        return request
    }
}

extension Managed where Self: NSManagedObject {
    static var entity: NSEntityDescription { return entity()  }
    static var entityName: String { return String(describing: self) }
    
    /// Note how we only evaluate the predicate when the object isn’t a fault. Otherwise, we’d risk triggering a lot of faults, which would be expensive. Next, we check if the managed object is the desired class, and if so, if it matches the predicate.
    
    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate, returnsObjectsAsFaults: Bool = false, propertiesToFetch: [String]? = nil) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = returnsObjectsAsFaults
                request.propertiesToFetch = propertiesToFetch
                request.fetchLimit = 1
            }.first
        }
        return object
    }
    
    static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
    static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return try! context.count(for: request)
    }
    
    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
}

