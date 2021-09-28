//
//  OrderDetailViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

class OrderDetailViewModel: NSObject {
    
    init(products: [Product], order: Order?) {
        self.products = products
        self.order = order
    }
    
    var order: Order?
    
    let products: [Product]
}
