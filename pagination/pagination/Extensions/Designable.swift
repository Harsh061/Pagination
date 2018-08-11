//
//  View+Extension.swift
//  pagination
//
//  Created by Harshit Parikh on 09/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//
import UIKit

@IBDesignable
// MARK: - UIView Designable
extension UIView {

    // MARK: - Border color
    @IBInspectable var borderColor: UIColor? {
        get {
            return self.borderColor
        } set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

    // MARK: - Border Width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }

    // MARK: - corner radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }

}

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes:[NSAttributedStringKey.foregroundColor: newValue ?? .gray])
        }
    }
}
