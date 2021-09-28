//
//  UITextFieldExtensions.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        publisher(for: .editingChanged)
            .map { self.text ?? "" }
            .eraseToAnyPublisher()
    }
}
