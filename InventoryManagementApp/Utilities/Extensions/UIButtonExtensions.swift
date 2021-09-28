//
//  UIButtonExtensions.swift
//  InventoryManagementApp
//
//  Created by Mewan on 26/09/2021.
//

import UIKit

extension UIButton {
    var tapPublisher: EventPublisher {
        publisher(for: .touchUpInside)
    }
}
