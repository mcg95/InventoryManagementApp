//
//  ProductCellViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import Foundation

class ProductCellViewModel: NSObject {
    
    init(product: Product) {
        self.product = product
    }
    
    let product: Product
}
