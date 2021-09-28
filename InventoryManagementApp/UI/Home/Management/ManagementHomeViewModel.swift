//
//  ManagementHomeViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import Foundation

class ManagementHomeViewModel: NSObject {
    
    init(userRole: UserRole) {
        self.userRole = userRole
    }
    
    let userRole: UserRole
}
