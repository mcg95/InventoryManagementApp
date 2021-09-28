//
//  UIViewExtensions.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 28/09/2021.
//

import UIKit

extension UIView {
    
    ///
    public func constraints(pinningEdgesTo view: UIView) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = [
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        return constraints
    }
    
    ///
    public func constraints(pinningEdgesTo layoutGuide: UILayoutGuide) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = [
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
        ]
        return constraints
    }
    
    ///
    public func constraints(centeringIn view: UIView) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
        return constraints
    }
}
