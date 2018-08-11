//
//  AlertViewControllerExtension.swift
//  pagination
//
//  Created by Harshit Parikh on 10/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import Foundation
import UIKit

protocol AlertViewProtocol: class {
    func showAlert(title: String, message: String)
}

extension AlertViewProtocol {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
