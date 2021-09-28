//
//  OrderListCoordinator.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 28/09/2021.
//

import UIKit

protocol OrderListCoordinatorDelegate: NSObjectProtocol {
    
    func orderListCoordinatorDidFinish(_ orderListCoordinator: OrderListCoordinator)
}

class OrderListCoordinator: NSObject {
    //----------------------------------------
    // MARK:- Initialization
    //----------------------------------------

    init(managementHomeViewController: ManagementHomeViewController) {
        self.managementHomeViewController = managementHomeViewController
        
        super.init()
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "OrderList", bundle: nil)
        if let orderListViewController = storyboard.instantiateViewController(withIdentifier: "OrderList") as? OrderListViewController {
            orderListViewController.delegate = self
            orderListViewController.viewModel = OrderListViewModel()
            
            self.orderListViewController = orderListViewController
            managementHomeViewController.navigationController?.pushViewController(orderListViewController, animated: true)
        }
    }
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: OrderListCoordinatorDelegate?

    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var orderListViewController: OrderListViewController?
    
    private var orderDetailViewController: OrderDetailViewController?
    
    private let managementHomeViewController: ManagementHomeViewController
}

//----------------------------------------
// MARK:- Order List View Controller Delegate
//----------------------------------------

extension OrderListCoordinator: OrderListViewControllerDelegate {
    func orderListViewControllerPresentOrderDetail(_ viewController: OrderListViewController, order: Order?) {
        let storyboard = UIStoryboard(name: "OrderDetail", bundle: nil)
        if let orderDetailViewController = storyboard.instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailViewController {
            orderDetailViewController.delegate = self
            orderDetailViewController.viewModel = OrderDetailViewModel(products: viewController.viewModel.products, order: order)
            viewController.present(orderDetailViewController, animated: true)
            
            self.orderDetailViewController = orderDetailViewController
        }
    }
    
    func orderListViewControllerDidFinish(_ viewController: OrderListViewController) {
        delegate?.orderListCoordinatorDidFinish(self)
    }
}

//----------------------------------------
// MARK:- Order Detail View Controller Delegate
//----------------------------------------

extension OrderListCoordinator: OrderDetailViewControllerDelegate {
    func orderDetailViewControllerDidSubmit(_ viewController: OrderDetailViewController, order: Order?) {
        viewController.dismiss(animated: true)
        
        guard let order = order else { return }
        
        orderListViewController?.viewModel.saveOrder(order: order)
    }
}
