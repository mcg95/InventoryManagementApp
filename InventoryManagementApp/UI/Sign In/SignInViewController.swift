//
//  ViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import UIKit
import Combine

protocol SignInViewControllerDelegate: NSObjectProtocol {
        
    func signInViewControllerIsSuccess(_ signInViewController: UIViewController, role: UserRole)
}

class SignInViewController: UIViewController {
    //----------------------------------------
    // MARK:- Lifecycle
    //----------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SignInViewModel()
        startObserving()
    }
    
    //----------------------------------------
    // MARK:- Start Observing
    //----------------------------------------
    
    private func startObserving() {
        usernameTextField.textPublisher.combineLatest(passwordTextField.textPublisher)
            .map(SignInParams.init)
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.viewModel.loginParams = $0
            }.store(in: &cancellables)
        
        signInButton.publisher(for: .touchUpInside)
            .sink {
                self.viewModel.performLogin()
            }.store(in: &cancellables)
        
        resetButton.publisher(for: .touchUpInside)
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.usernameTextField.text = nil
                self.passwordTextField.text = nil
            }.store(in: &cancellables)
        
        viewModel.isLoginSuccess.sink { isSuccess, role in
            if isSuccess {
                self.delegate?.signInViewControllerIsSuccess(self, role: role ?? .admin)
            } else {
                if self.viewModel.loginParams != nil {
                    toast("Invalid Credentials.", size: .small, duration: .normal)
                    self.resetButton.sendActions(for: .touchUpInside)
                }
            }
        }.store(in: &cancellables)
    }
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: SignInViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: SignInViewModel!
    
    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var cancellables = Set<AnyCancellable>()
    
    //----------------------------------------
    // MARK:- Outlets
    //----------------------------------------
    
    @IBOutlet private var usernameTextField: UITextField!
    
    @IBOutlet private var passwordTextField: UITextField!
    
    @IBOutlet private var signInButton: UIButton!
    
    @IBOutlet private var resetButton: UIButton!
}
