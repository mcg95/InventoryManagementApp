//
//  EmployeeCell.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation
import UIKit
import Combine

class EmployeeCell: UICollectionViewCell, NibReusable {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.forEach({ $0.cancel() })
    }
    
    func bindViewModel(_ viewModel: EmployeeCellViewModel) {
        idLabel.text = viewModel.employee.id.uuidString
        nameLabel.text = viewModel.employee.name
        roleLabel.text = viewModel.employee.role.capitalized
    }
    
    var editButtonPublisher: UIControl.EventPublisher {
        editButton.publisher(for: .touchUpInside)
    }
    
    var deleteButtonPublisher: UIControl.EventPublisher {
        deleteButton.publisher(for: .touchUpInside)
    }
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet private var idLabel: UILabel!
    
    @IBOutlet private var nameLabel: UILabel!

    @IBOutlet private var roleLabel: UILabel!
    
    @IBOutlet private var editButton: UIButton!

    @IBOutlet private var deleteButton: UIButton!
}
