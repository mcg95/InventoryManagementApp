//
//  BuyCartCell.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation
import UIKit
import Combine

class BuyCartCell: UICollectionViewCell, NibReusable {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.forEach({ $0.cancel() })
    }
    
    func bindViewModel(_ viewModel: BuyCartCellViewModel) {
        nameLabel.text = viewModel.cart.productName
        totalPriceLabel.text = "RM \(String(viewModel.cart.totalPrice))"
        quantityLabel.text = String(viewModel.cart.quantity)
    }
    
    var deleteButtonPublisher: UIControl.EventPublisher {
        deleteButton.publisher(for: .touchUpInside)
    }
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet private var quantityLabel: UILabel!
    
    @IBOutlet private var nameLabel: UILabel!

    @IBOutlet private var totalPriceLabel: UILabel!
    
    @IBOutlet private var deleteButton: UIButton!
}
