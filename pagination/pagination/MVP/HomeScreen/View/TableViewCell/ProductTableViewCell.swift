//
//  ProductTableViewCell.swift
//  pagination
//
//  Created by Harshit Parikh on 09/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import UIKit
import Kingfisher

class ProductTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    
    // MARK: - Outlets
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        productView.shadowPath(cornerRadius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Function to set data in cells
    /// - Parameters:
    ///   - indexPath: takes user model as input
    func setupData(model: UserInfoModel) {
        var imageURL: URL? = nil
        let imageData = model.userImage
        if let url: URL =  URL(string: imageData) {
            imageURL = url
        }
        
        if imageURL != nil {
            self.userProfileImage.kf.setImage(with: imageURL)
        } else {
            self.userProfileImage.image = #imageLiteral(resourceName: "placeholderIcon")
        }
        self.userNameLabel.text = model.firstName + " " + model.lastName
        self.userIdLabel.text = "\(model.id)"
    }
    
}
