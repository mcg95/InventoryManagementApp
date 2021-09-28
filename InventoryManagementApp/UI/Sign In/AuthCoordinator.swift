//
//  AuthCoordinator.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 28/09/2021.
//

import UIKit

protocol AuthCoordinatorDelegate: NSObjectProtocol {
    
    func authCoordinatorDidFinish(_ authCoordinator: AuthCoordinator, role: UserRole)
}

class AuthCoordinator: NSObject {
    //----------------------------------------
    // MARK:- Initialization
    //----------------------------------------

    init(mainViewController: MainViewController) {
        self.mainViewController = mainViewController
        
        super.init()
    }
    
    //----------------------------------------
    // MARK:- Start
    //----------------------------------------
    
    func start() {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let signInViewController = navigationController.topViewController as! SignInViewController
        signInViewController.delegate = self
        signInViewController.viewModel = SignInViewModel()
        
        
        mainViewController.addChild(navigationController)
        mainViewController.view.addSubview(navigationController.view)
        NSLayoutConstraint.activate(navigationController.view.constraints(pinningEdgesTo: mainViewController.view))
        navigationController.didMove(toParent: mainViewController)
        
        self.signInViewController = signInViewController
    }
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: AuthCoordinatorDelegate?
    
    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var signInViewController: SignInViewController?
    
    private let mainViewController: MainViewController
}

//----------------------------------------
// MARK:- Sign In View Controller Delegate
//----------------------------------------

extension AuthCoordinator: SignInViewControllerDelegate {
    func signInViewControllerIsSuccess(_ signInViewController: UIViewController, role: UserRole) {
        delegate?.authCoordinatorDidFinish(self, role: role)
    }
}
