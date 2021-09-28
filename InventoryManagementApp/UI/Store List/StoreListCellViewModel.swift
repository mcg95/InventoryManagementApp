//
//  StoreListCellViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

class StoreListCellViewModel: NSObject {
    
    init(product: Product) {
        self.product = product
    }
    
    let product: Product
}
