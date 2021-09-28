//
//  HomeCoordinator.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 28/09/2021.
//

import UIKit

protocol HomeCoordinatorDelegate: NSObjectProtocol {
    
    func homeCoordinatorDidFinish(_ homeCoordinator: HomeCoordinator)
}

class HomeCoordinator: NSObject {
    //----------------------------------------
    // MARK:- Initialization
    //----------------------------------------

    init(mainViewController: MainViewController) {
        self.mainViewController = mainViewController
        
        super.init()
    }
    
    func start(role: UserRole) {
        let storyboard = UIStoryboard(name: "ManagementHome", bundle: nil)
        if  let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController,
            let managementViewController = navigationController.topViewController as? ManagementHomeViewController {
            managementViewController.delegate = self
            managementViewController.viewModel = ManagementHomeViewModel(userRole: role)
            
            mainViewController.addChild(navigationController)
            mainViewController.view.addSubview(navigationController.view)
            NSLayoutConstraint.activate(navigationController.view.constraints(pinningEdgesTo: mainViewController.view))
            navigationController.didMove(toParent: mainViewController)
            
            self.managementHomeViewController = managementViewController
        }
    }
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: HomeCoordinatorDelegate?
    
    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var managementHomeViewController: ManagementHomeViewController?
    
    private var employeeListViewController: EmployeeListViewController?

    private var listViewController: ListViewController?

    private var orderListCoordinator: OrderListCoordinator?

    private var customerListViewController: CustomerListViewController?
    
    private let mainViewController: MainViewController
}

//----------------------------------------
// MARK:- Management Home View Controller Delegate
//----------------------------------------

extension HomeCoordinator: ManagementHomeViewControllerDelegate {
    func managementHomeViewControllerDidFinish(_ viewController: ManagementHomeViewController) {
        delegate?.homeCoordinatorDidFinish(self)
    }
    
    func managementHomeViewControllerPresentCustomerList(_ viewController: ManagementHomeViewController) {
        let storyboard = UIStoryboard(name: "CustomerList", bundle: nil)
        if let customerListViewController = storyboard.instantiateViewController(withIdentifier: "CustomerList") as? CustomerListViewController {
            customerListViewController.delegate = self
            customerListViewController.viewModel = CustomerListViewModel()
            
            self.customerListViewController = customerListViewController
            managementHomeViewController?.navigationController?.pushViewController(customerListViewController, animated: true)
        }
    }
    
    func managementHomeViewControllerPresentEmployeeList(_ viewController: ManagementHomeViewController) {
        let storyboard = UIStoryboard(name: "EmployeeList", bundle: nil)
        if let employeeListViewController = storyboard.instantiateViewController(withIdentifier: "EmployeeList") as? EmployeeListViewController {
            employeeListViewController.delegate = self
            employeeListViewController.viewModel = EmployeeListViewModel()
            
            self.employeeListViewController = employeeListViewController
            managementHomeViewController?.navigationController?.pushViewController(employeeListViewController, animated: true)
        }
    }
    
    func managementHomeViewControllerPresentOrderList(_ viewController: ManagementHomeViewController) {
        let orderListCoordinator = OrderListCoordinator(managementHomeViewController: viewController)
        orderListCoordinator.delegate = self
        orderListCoordinator.start()
        
        self.orderListCoordinator = orderListCoordinator
    }
    
    func managementHomeViewControllerPresentProductList(_ viewController: ManagementHomeViewController) {
        let storyboard = UIStoryboard(name: "List", bundle: nil)
        if let listViewController = storyboard.instantiateViewController(withIdentifier: "List") as? ListViewController {
            listViewController.delegate = self
            listViewController.viewModel = ListViewModel(listType: .product)
            
            self.listViewController = listViewController
            managementHomeViewController?.navigationController?.pushViewController(listViewController, animated: true)
        }
    }
}

//----------------------------------------
// MARK:- Order Coordinator Delegate
//----------------------------------------

extension HomeCoordinator: OrderListCoordinatorDelegate {
    func orderListCoordinatorDidFinish(_ orderListCoordinator: OrderListCoordinator) {
        self.orderListCoordinator = nil
        managementHomeViewController?.navigationController?.popViewController(animated: true)
    }
}

//----------------------------------------
// MARK:- Employee List View Controller Delegate
//----------------------------------------

extension HomeCoordinator: EmployeeListViewControllerDelegate {
    func employeeListViewControllerDidFinish(_ viewController: EmployeeListViewController) {
        employeeListViewController = nil
        managementHomeViewController?.navigationController?.popViewController(animated: true)
    }
}

//----------------------------------------
// MARK:- Product List View Controller Delegate
//----------------------------------------

extension HomeCoordinator: ListViewControllerDelegate {
    func listViewControllerDidFinish(_ viewController: ListViewController) {
        listViewController = nil
        managementHomeViewController?.navigationController?.popViewController(animated: true)
    }
}

//----------------------------------------
// MARK:- Customer List View Controller Delegate
//----------------------------------------

extension HomeCoordinator: CustomerListViewControllerDelegate {
    func customerListViewControllerDidFinish(_ viewController: CustomerListViewController) {
        customerListViewController = nil
        managementHomeViewController?.navigationController?.popViewController(animated: true)
    }
}
