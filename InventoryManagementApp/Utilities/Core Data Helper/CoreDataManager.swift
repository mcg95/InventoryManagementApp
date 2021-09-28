//
//  CoreDataManager.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import Foundation
import CoreData
//
//class CoreDataManager {
//
//    private static let _sharedInstance = CoreDataManager()
//    private lazy var coreDataStack: CoreDataStack = ServiceContainer.sharedInstance.coreDataStack
//
//    private init() { }
//
//    static func sharedInstance() -> CoreDataManager {
//        return _sharedInstance
//    }
//
//    // TODO: Temporary
//    /// Use this property to access managed object context associated with the main queue.
//    var mainContext: NSManagedObjectContext {
//        return coreDataStack.workerContext
//    }
//
//    func saveContext() {
//        do {
//            try mainContext.saveIfNeeded()
//        } catch let error {
//            // TODO: Log to crashlytics
//            Logger.logAndRecord("COREDATA CREATE CONVERSATION", error)
//        }
//    }
//}
