//
//  ViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import UIKit
import Combine

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SignInViewModel()
        startObserving()
    }
    
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
                switch role {
                case .employee,
                        .admin:
                    let storyboard = UIStoryboard(name: "ManagementHome", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ManagementHome") as? ManagementHomeViewController {
//                        vc.delegate = self
                        vc.viewModel = ManagementHomeViewModel(userRole: role!)
                        self.navigationController?.viewControllers[0] = vc
                    }
                    
                case .customer:
                    let storyboard = UIStoryboard(name: "StoreList", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "StoreList") as? StoreListViewController {
//                        vc.delegate = self
//                        vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
                        self.navigationController?.viewControllers[0] = vc
                    }
                    
                default: break
                }
            } else {
                toast("Invalid Credentials.", size: .small, duration: .normal)
                self.resetButton.sendActions(for: .touchUpInside)
            }
        }.store(in: &cancellables)
    }
    
    var viewModel: SignInViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet private var usernameTextField: UITextField!
    
    @IBOutlet private var passwordTextField: UITextField!
    
    @IBOutlet private var signInButton: UIButton!
    
    @IBOutlet private var resetButton: UIButton!
}
