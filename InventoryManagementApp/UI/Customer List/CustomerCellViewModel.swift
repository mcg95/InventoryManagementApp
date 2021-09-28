//
//  CustomerCellViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

class CustomerCellViewModel: NSObject {
    
    init(customer: Customer) {
        self.customer = customer
    }
    
    let customer: Customer
}
