import UIKit

/// Internal enumeration for specifying the type of transition to apply when moving between flows.
enum TransitionStyle {
    case push
    case crossDissolve
}

// TODO: Lots of common code. Needs refactoring.
extension UIViewController {
    //----------------------------------------
    // MARK:- Transitions
    //----------------------------------------
    
    /// TODO: Not really clean. Needs an API review.
    func transitionWithoutAnimation(from fromViewController: UIViewController?,
                                    to toViewController: UIViewController,
                                    containerView: UIView) {
        let toView = toViewController.view!
        
        // Add the to view controller and to view.
        addChild(toViewController)
        containerView.addSubview(toView)
        // TODO: somewhat leaky abstraction.
        NSLayoutConstraint.activate(toView.constraints(pinningEdgesTo: containerView))
        
        if let fromViewController = fromViewController {
            let fromView = fromViewController.view!
            // Inform the from view controller about impending move.
            fromViewController.willMove(toParent: nil)
            // Update from view controller.
            fromView.removeFromSuperview()
            fromViewController.removeFromParent()
        }
        
        // Update to view controller.
        toViewController.didMove(toParent: self)
    }
    
    ///
    func transition(from fromViewController: UIViewController,
                    to toViewController: UIViewController,
                    transitionStyle: TransitionStyle,
                    completion: ((Bool) -> Void)? = nil) {
        switch transitionStyle {
        case .push:
            transitionWithPushEffect(from: fromViewController, to: toViewController, completion: completion)
            
        case .crossDissolve:
            transitionWithCrossDissolveEffect(from: fromViewController, to: toViewController, completion: completion)
        }
    }
    
    ///
    private func transitionWithPushEffect(from fromViewController: UIViewController,
                                          to toViewController: UIViewController,
                                          completion: ((Bool) -> Void)? = nil) {
        // Participating views and view controllers.
        let parentViewController = fromViewController.parent!
        let containerView = fromViewController.view.superview!
        let fromView = fromViewController.view!
        let toView = toViewController.view!
        
        // Add the to view controller and to view.
        parentViewController.addChild(toViewController)
        containerView.addSubview(toView)
        NSLayoutConstraint.activate(toView.constraints(pinningEdgesTo: containerView))
        
        // Inform the from view controller about impending move.
        fromViewController.willMove(toParent: nil)
        
        // Create a shadow overlay view that overlays the from view controller during the transition.
        let shadowOverlayView = UIView()
        shadowOverlayView.translatesAutoresizingMaskIntoConstraints = false
        shadowOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        // The shadow overlay view starts out invisible.
        shadowOverlayView.alpha = 0.0
        containerView.insertSubview(shadowOverlayView, belowSubview: toView)
        NSLayoutConstraint.activate(shadowOverlayView.constraints(pinningEdgesTo: fromView))
        
        // Place the to view to the right of the container.
        toView.transform = CGAffineTransform(translationX: containerView.bounds.width, y: 0.0)
        
        // Add a shadow edge layer under the to view for the duration of the transition.
        toView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).cgPath
        toView.layer.shadowColor = UIColor.black.cgColor
        toView.layer.shadowOpacity = 0.3
        toView.layer.shadowOffset = CGSize(width: -2.0, height: 0.0)
        toView.layer.shadowRadius = 4.0
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: [ .curveEaseInOut ], animations: {
            // Animate the shadow view in.
            shadowOverlayView.alpha = 1.0
            
            // Animate the from view out.
            fromView.transform = CGAffineTransform(translationX: -fromView.frame.width * 0.67, y: 0.0)
            
            // Animate the to view in.
            toView.transform = .identity
        }, completion: { finished in
            // Clean up shadows.
            toView.layer.shadowPath = nil
            shadowOverlayView.removeFromSuperview()
            
            // Update from view controller.
            fromView.removeFromSuperview()
            fromViewController.removeFromParent()
            
            // Update to view controller.
            toViewController.didMove(toParent: parentViewController)
            
            completion?(finished)
        })
    }
    
    ///
    private func transitionWithCrossDissolveEffect(from fromViewController: UIViewController,
                                                   to toViewController: UIViewController,
                                                   completion: ((Bool) -> Void)? = nil) {
        // Participating views and view controllers.
        let parentViewController = fromViewController.parent!
        let containerView = fromViewController.view.superview!
        let fromView = fromViewController.view!
        let toView = toViewController.view!
        
        // Add the to view controller and to view.
        parentViewController.addChild(toViewController)
        containerView.addSubview(toView)
        NSLayoutConstraint.activate(toView.constraints(pinningEdgesTo: containerView))
        
        // Inform the from view controller about impending move.
        fromViewController.willMove(toParent: nil)
        
        // To view starts out invisible.
        toView.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [ .curveEaseInOut ], animations: {
            // Animate the from view out.
            fromView.alpha = 0.0
            
            // Animate the to view in.
            toView.alpha = 1.0
        }, completion: { finished in
            // Update from view controller.
            fromView.removeFromSuperview()
            fromViewController.removeFromParent()
            
            // Update to view controller.
            toViewController.didMove(toParent: parentViewController)
            
            completion?(finished)
        })
    }
}
