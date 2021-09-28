//
//  BuyCartCellViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

class BuyCartCellViewModel: NSObject {
    
    init(cart: BuyCart) {
        self.cart = cart
    }
    
    let cart: BuyCart
}
