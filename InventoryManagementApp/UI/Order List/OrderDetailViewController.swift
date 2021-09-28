//
//  OrderDetailViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import UIKit
import Combine

protocol OrderDetailViewControllerDelegate: NSObjectProtocol {    
    func orderDetailViewControllerDidSubmit(_ viewController: OrderDetailViewController,
                                            order: Order?)
}

class OrderDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        startObserving()
    }
    
    private func startObserving() {
        saveButton.publisher(for: .touchUpInside)
            .sink {
                self.delegate?.orderDetailViewControllerDidSubmit(self, order: self.viewModel.order)
            }.store(in: &cancellables)
        
        cancelButton.publisher(for: .touchUpInside)
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.orderDetailViewControllerDidSubmit(self, order: nil)
            }.store(in: &cancellables)
        
        quantityTextField.textPublisher.sink { text in
            guard let quantity = Double(text) else { return }
            
            self.viewModel.order?.quantity = Int64(text) ?? 0
            
            self.priceLabel.text = String((self.viewModel.order?.product?.price)! * quantity)
        }.store(in: &cancellables)
    }
    
    private func configureViews() {
        let uuid = UUID()
        orderIdTextField.text = viewModel.order?.id.uuidString ?? uuid.uuidString
        if let price = viewModel.order?.product?.price {
            productPriceTextField.text = "RM \(String(price))"
            saveButton.titleLabel?.text = "Update Order"
        }
        if let quantity = viewModel.order?.quantity {
            quantityTextField.text = String(quantity)
            quantityTextField.isEnabled = true
            
            self.priceLabel.text = "RM \(String((self.viewModel.order?.product?.price)! * Double(quantity)))"
        }
        
        let menuElements: [UIAction] = viewModel.products.map({ product in
            let action = UIAction(title: product.name, subtitle: String(product.price), image: nil, identifier: nil) { action in
                if self.viewModel.order == nil {
                    self.viewModel.order = Order(id: uuid,
                                                 productId: product.id,
                                                 price: product.price,
                                                 quantity: 0,
                                                 product: product)
                } else {
                    self.viewModel.order?.product = product
                }
                self.productPriceTextField.text = "RM \(String(product.price))"
                self.productNameButton.setTitle(product.name, for: .normal)
                self.quantityTextField.isEnabled = self.viewModel.order?.product != nil
            }
            return action
        })
        productNameButton.menu = UIMenu(title: "Product List", image: nil, identifier: nil, options: .singleSelection, children: menuElements)
        
        productNameButton.setTitle(viewModel.order?.product?.name ?? "Select Product", for: .normal)
    }
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: OrderDetailViewModel!
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: OrderDetailViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var cancellables = Set<AnyCancellable>()
    
    //----------------------------------------
    // MARK:- Outlets
    //----------------------------------------
    
    @IBOutlet private var saveButton: UIButton!

    @IBOutlet private var cancelButton: UIButton!
    
    @IBOutlet private var productNameButton: UIButton!

    @IBOutlet private var orderIdTextField: UITextField!
    
    @IBOutlet private var productPriceTextField: UITextField!

    @IBOutlet private var quantityTextField: UITextField!

    @IBOutlet private var priceLabel: UILabel!
}
