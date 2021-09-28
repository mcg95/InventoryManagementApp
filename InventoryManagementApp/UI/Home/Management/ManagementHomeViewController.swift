//
//  ManagementHomeViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import Foundation
import UIKit
import Combine

protocol ManagementHomeViewControllerDelegate: NSObjectProtocol {
        
    func managementHomeViewControllerDidFinish(_ viewController: ManagementHomeViewController)
    
    func managementHomeViewControllerPresentCustomerList(_ viewController: ManagementHomeViewController)

    func managementHomeViewControllerPresentEmployeeList(_ viewController: ManagementHomeViewController)

    func managementHomeViewControllerPresentOrderList(_ viewController: ManagementHomeViewController)
    
    func managementHomeViewControllerPresentProductList(_ viewController: ManagementHomeViewController)
}

class ManagementHomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch viewModel.userRole {
        case .employee:
            manageCustomerButton.isHidden = true
            manageEmployeeButton.isHidden = true
            
        case .admin:
            manageOrderButton.isHidden = true
            manageProductButton.isHidden = true
            
        default: break
        }
        
        let logoutItemButton = UIBarButtonItem(title: "Logout",
                                            style: .plain,
                                            target: self,
                                            action: #selector(logOutButtonDidTap))
        navigationItem.leftBarButtonItem = logoutItemButton

        startObserving()
    }
    
    private func startObserving() {
        manageCustomerButton.publisher(for: .touchUpInside)
            .sink {
                self.delegate?.managementHomeViewControllerPresentCustomerList(self)
            }.store(in: &cancellables)
        
        manageEmployeeButton.publisher(for: .touchUpInside)
            .sink {
                self.delegate?.managementHomeViewControllerPresentEmployeeList(self)
            }.store(in: &cancellables)
        
        manageOrderButton.publisher(for: .touchUpInside)
            .sink {
                self.delegate?.managementHomeViewControllerPresentOrderList(self)
            }.store(in: &cancellables)
        
        manageProductButton.publisher(for: .touchUpInside)
            .sink {
                self.delegate?.managementHomeViewControllerPresentProductList(self)
            }.store(in: &cancellables)
    }
    
    @objc func logOutButtonDidTap(_ sender: UIBarButtonItem) {
        delegate?.managementHomeViewControllerDidFinish(self)
    }
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: ManagementHomeViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: ManagementHomeViewModel!
    
    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var cancellables = Set<AnyCancellable>()
    
    //----------------------------------------
    // MARK:- Outlets
    //----------------------------------------
    
    @IBOutlet private var manageCustomerButton: UIButton!
    
    @IBOutlet private var manageProductButton: UIButton!
    
    @IBOutlet private var manageOrderButton: UIButton!

    @IBOutlet private var manageEmployeeButton: UIButton!
}
