//
//  SortTableViewCell.swift
//  pagination
//
//  Created by Harshit Parikh on 11/08/18.
//  Copyright © 2018 Harshit Parikh. All rights reserved.
//

import UIKit

struct SortTableViewCellModel: CellDataModelProtocol {
    var identifier: String
    var title: String
    var subTitle: String
    var data: String?
    var isSortSelected: Bool = false
    
    init(identifier: String, title: String, subTitle: String, data: String? = nil) {
        self.identifier = identifier
        self.title = title
        self.subTitle = subTitle
        self.data = data
    }
}

class SortTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Function to set data in cells
    /// - Parameters:
    ///   - indexPath: takes sort table cell model as input
    func setupView(viewModel: SortTableViewCellModel) {
        self.headingLabel.text = viewModel.title
        self.subHeadingLabel.text = viewModel.subTitle
        if viewModel.isSortSelected {
            self.headingLabel.textColor = UIColor(red: 0 / 255.0, green: 84 / 255.0, blue: 147 / 255.0, alpha: 1.0)
            self.subHeadingLabel.textColor = UIColor(red: 0 / 255.0, green: 84 / 255.0, blue: 147 / 255.0, alpha: 1.0)
        } else {
            self.headingLabel.textColor = UIColor.black
            self.subHeadingLabel.textColor = UIColor.black
        }
    }
    
}
