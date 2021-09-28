//
//  OrderCellViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import Foundation

class OrderCellViewModel: NSObject {
    
    init(order: Order) {
        self.order = order
    }
    
    let order: Order
}
