//
//  SlideInPresentationManager.swift
//  MedalCount
//
//  Created by Dheeraj on 31/12/17.
//  Copyright © 2017 Ron Kliffer. All rights reserved.
//

import UIKit

enum PresentationStyle {
   case overlay
   case reveal
   case ssa
}

enum PresentationDirection {
  case left(PresentationStyle)
  case right
  case top
  case bottom
}

class SlideInPresentationManager: NSObject {

  var direction = PresentationDirection.left(.overlay)
  var disableCompactHeight = false
}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
    let presentedViewController = SlideInPresentationController(presentedViewController: presented, presenting: presenting, direction: direction)
    presentedViewController.delegate = self
    return presentedViewController
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return SlideInPresentationAnimator(direction: direction, isPresentation: false)
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInPresentationAnimator(direction: direction, isPresentation: true)
  }
}

extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
       return .overFullScreen
    } else {
      return .none
    }
  }
  
  func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    guard style == .overFullScreen else {
        return nil
    }
    
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RotateViewController")
  }
}
