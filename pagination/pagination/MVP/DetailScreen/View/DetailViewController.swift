//
//  DetailViewController.swift
//  pagination
//
//  Created by Harshit Parikh on 10/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    var userModel: UserInfoModel?
    private var presenter: DetailPresenter!
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    
    // MARK: - Button Actions
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profilePicBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ImageViewController.identifier) as? ImageViewController {
            if let model = userModel {
                vc.userImageString = model.userImage
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenterSetup()
        setupNavigation()
        setupUserData()
    }
    
    /// Function to setup presenter
    private func presenterSetup() {
        self.presenter = DetailPresenter(view: self)
    }
    
    /// Function to setup navigation
    private func setupNavigation() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    /// FUnctio to setup user data
    private func setupUserData() {
        if let model = userModel {
            var imageURL: URL? = nil
            let imageData = model.userImage
            if let url: URL =  URL(string: imageData) {
                imageURL = url
            }
            
            if imageURL != nil {
                self.profileBackgroundImage.kf.setImage(with: imageURL)
                self.profileImage.kf.setImage(with: imageURL)
            } else {
                self.profileImage.image = #imageLiteral(resourceName: "placeholderIcon")
            }
//            self.profileBackgroundImage.image = #imageLiteral(resourceName: "background")
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = profileBackgroundImage.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            profileBackgroundImage.addSubview(blurEffectView)
            self.titleLabel.text = "Contact Id: " + "\(model.id)"
            self.firstNameLabel.text = model.firstName
            self.lastNameLabel.text = model.lastName
        }
        
    }

}

extension DetailViewController: DetailPresenterProtocol {
    
}
