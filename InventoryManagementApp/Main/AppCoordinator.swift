//
//  AppCoordinator.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 28/09/2021.
//

import UIKit

/// Coordinator for the overall app.
///
/// Acts as the delegate for app intro, but delegates to child coordinators for other flows.
class AppCoordinator: NSObject {
    //----------------------------------------
    // MARK:- Initialization
    //----------------------------------------

    init (mainViewController: MainViewController) {
        self.mainViewController = mainViewController
        
        super.init()
    }
    
    //----------------------------------------
    // MARK:- Auth Flow
    //----------------------------------------
    
    func startAuthFlow(transitionStyle: TransitionStyle = .push) {
        if let activeViewController = activeViewController {
            mainViewController.transition(from: activeViewController,
                                          to: mainViewController,
                                          transitionStyle: transitionStyle)
        } else {
            let authCoordinator = AuthCoordinator(mainViewController: mainViewController)
            authCoordinator.delegate = self
            authCoordinator.start()
            self.authCoordinator = authCoordinator
        }
    }
    
    //----------------------------------------
    // MARK:- Main flow
    //----------------------------------------

    private func startMainFlow(transitionStyle: TransitionStyle = .push, role: UserRole) {
        switch role {
        case .employee,
                .admin:
            let homeCoordinator = HomeCoordinator(mainViewController: mainViewController)
            homeCoordinator.delegate = self
            homeCoordinator.start(role: role)
            
            self.homeCoordinator = homeCoordinator
            
        case .customer:
            let storeListCoordinator = StoreListCoordinator(mainViewController: mainViewController)
            storeListCoordinator.delegate = self
            storeListCoordinator.start()
            
            self.storeListCoordinator = storeListCoordinator
        }
    }
    
    //----------------------------------------
    // MARK:- Starting flows
    //----------------------------------------

    // Managed view controllers
    private let mainViewController: MainViewController
    
    // View controllers that are hosted in the main view controller
    private var activeViewController: UIViewController?
    
    // Child coordinators
    
    private var authCoordinator: AuthCoordinator?

    private var homeCoordinator: HomeCoordinator?
    
    private var storeListCoordinator: StoreListCoordinator?
}

//----------------------------------------
// MARK:- Auth Coordinator Delegate
//----------------------------------------

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish(_ authCoordinator: AuthCoordinator, role: UserRole) {
        self.authCoordinator = nil
        startMainFlow(role: role)
    }
}

//----------------------------------------
// MARK:- Auth Coordinator Delegate
//----------------------------------------

extension AppCoordinator: StoreListCoordinatorDelegate {
    func storeListCoordinatorDidFinish(_ homeCoordinator: StoreListCoordinator) {
        self.storeListCoordinator = nil
        startAuthFlow()
    }
}

//----------------------------------------
// MARK:- Auth Coordinator Delegate
//----------------------------------------

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorDidFinish(_ homeCoordinator: HomeCoordinator) {
        self.homeCoordinator = nil
        startAuthFlow()
    }
}
