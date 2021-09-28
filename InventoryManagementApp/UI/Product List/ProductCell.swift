//
//  ProductCell.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import Foundation
import UIKit
import Combine

class ProductCell: UICollectionViewCell, NibReusable {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.forEach({ $0.cancel() })
    }
    
    func bindViewModel(_ viewModel: ProductCellViewModel) {
        idLabel.text = viewModel.product.id.uuidString
        nameLabel.text = viewModel.product.name
        priceLabel.text = "RM \(String(viewModel.product.price))"
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
    
    @IBOutlet private var editButton: UIButton!

    @IBOutlet private var deleteButton: UIButton!
}
