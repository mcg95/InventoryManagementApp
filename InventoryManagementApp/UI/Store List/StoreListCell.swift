//
//  StoreListCell.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

import Foundation
import UIKit
import Combine

class StoreListCell: UICollectionViewCell, NibReusable {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.forEach({ $0.cancel() })
    }
    
    func bindViewModel(_ viewModel: StoreListCellViewModel) {
        nameLabel.text = viewModel.product.name
        priceLabel.text = "RM \(String(viewModel.product.price))"
        quantityTextField.text = "1"
        
        quantityTextField.textPublisher.sink { text in
            guard let quantity = Double(text) else { return }
            
            self.quantityTextPublisher.send(text)
            self.priceLabel.text = String(quantity * viewModel.product.price)
        }.store(in: &cancellables)
        
        addToCartButtonPublisher.sink { _ in
            self.quantityTextField.text = "1"
        }.store(in: &cancellables)
    }
    
    var addToCartButtonPublisher: UIControl.EventPublisher {
        addToCartButton.publisher(for: .touchUpInside)
    }
    
    var quantityTextPublisher = CurrentValueSubject<String,Never>("1")
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet private var quantityTextField: UITextField!
    
    @IBOutlet private var nameLabel: UILabel!

    @IBOutlet private var priceLabel: UILabel!
    
    @IBOutlet private var addToCartButton: UIButton!
}
