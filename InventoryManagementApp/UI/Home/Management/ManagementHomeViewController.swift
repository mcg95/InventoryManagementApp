//
//  ManagementHomeViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import Foundation
import UIKit
import Combine

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
                let storyboard = UIStoryboard(name: "CustomerList", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CustomerList") as? CustomerListViewController {
//                        vc.delegate = self
//                        vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &cancellables)
        
        manageEmployeeButton.publisher(for: .touchUpInside)
            .sink {
                let storyboard = UIStoryboard(name: "EmployeeList", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "EmployeeList") as? EmployeeListViewController {
//                        vc.delegate = self
//                        vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &cancellables)
        
        manageOrderButton.publisher(for: .touchUpInside)
            .sink {
                let storyboard = UIStoryboard(name: "OrderList", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "OrderList") as? OrderListViewController {
//                        vc.delegate = self
//                        vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &cancellables)
        
        manageProductButton.publisher(for: .touchUpInside)
            .sink {
                let storyboard = UIStoryboard(name: "List", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "List") as? ListViewController {
//                        vc.delegate = self
//                        vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &cancellables)
    }
    
    @objc func logOutButtonDidTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SignIn") as? SignInViewController {
//                        vc.delegate = self
//                        vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
            self.navigationController?.viewControllers[0] = vc
        }
    }
    
    var viewModel: ManagementHomeViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet private var manageCustomerButton: UIButton!
    
    @IBOutlet private var manageProductButton: UIButton!
    
    @IBOutlet private var manageOrderButton: UIButton!

    @IBOutlet private var manageEmployeeButton: UIButton!
}
