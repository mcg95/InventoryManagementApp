//
//  OrderCell.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import UIKit
import Combine

class OrderCell: UICollectionViewCell, NibReusable {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.forEach({ $0.cancel() })
    }
    
    func bindViewModel(_ viewModel: OrderCellViewModel) {
        idLabel.text = viewModel.order.id.uuidString
        nameLabel.text = viewModel.order.product?.name
        priceLabel.text = "RM \(String(viewModel.order.price * Double(viewModel.order.quantity)))"
        quantityLabel.text = String(viewModel.order.quantity)
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

    @IBOutlet private var priceLabel: UILabel!
    
    @IBOutlet private var quantityLabel: UILabel!
    
    @IBOutlet private var editButton: UIButton!

    @IBOutlet private var deleteButton: UIButton!
}
