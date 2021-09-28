//
//  EmployeeCellViewModel.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

class EmployeeCellViewModel: NSObject {
    
    init(employee: Employee) {
        self.employee = employee
    }
    
    let employee: Employee
}
