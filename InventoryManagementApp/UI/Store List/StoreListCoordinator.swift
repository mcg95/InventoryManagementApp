//
//  StoreListCoordinator.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 28/09/2021.
//

import UIKit

protocol StoreListCoordinatorDelegate: NSObjectProtocol {
    
    func storeListCoordinatorDidFinish(_ storeListCoordinator: StoreListCoordinator)
}

class StoreListCoordinator: NSObject {
    //----------------------------------------
    // MARK:- Initialization
    //----------------------------------------

    init(mainViewController: MainViewController) {
        self.mainViewController = mainViewController
        
        super.init()
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "StoreList", bundle: nil)
        if  let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController,
            let storeListViewController = navigationController.topViewController as? StoreListViewController {
            storeListViewController.delegate = self
            storeListViewController.viewModel = StoreListViewModel()
            mainViewController.addChild(navigationController)
            mainViewController.view.addSubview(navigationController.view)
            NSLayoutConstraint.activate(navigationController.view.constraints(pinningEdgesTo: mainViewController.view))
            navigationController.didMove(toParent: mainViewController)
            
            self.storeListViewController = storeListViewController
        }
    }
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: StoreListCoordinatorDelegate?

    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var storeListViewController: StoreListViewController?
    
    private var buyCartViewController: BuyCartViewController?
    
    private let mainViewController: MainViewController
}

//----------------------------------------
// MARK:- Store List View Controller Delegate
//----------------------------------------

extension StoreListCoordinator: StoreListViewControllerDelegate {
    func storeListViewControllerDidFinish(_ viewController: StoreListViewController) {
        delegate?.storeListCoordinatorDidFinish(self)
    }
    
    func storeListViewControllerPresentCart(_ viewController: StoreListViewController) {
        let storyboard = UIStoryboard(name: "BuyCart", bundle: nil)
        if let buyCartViewController = storyboard.instantiateViewController(withIdentifier: "BuyCart") as? BuyCartViewController {
            buyCartViewController.delegate = self
            self.buyCartViewController = buyCartViewController
            
            viewController.navigationController?.pushViewController(buyCartViewController, animated: true)
        }
    }
}

//----------------------------------------
// MARK:- Buy Cart View Controller Delegate
//----------------------------------------

extension StoreListCoordinator: BuyCartViewControllerDelegate {
    func buyCartViewControllerDidFinish(_ viewController: BuyCartViewController) {
        storeListViewController?.navigationController?.popViewController(animated: true)
    }
}
