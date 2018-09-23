//
//  UserInfoTableViewCell.swift
//  
//
//  Created by Yota Nakamura on 2018/09/23.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    var userName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.image = UIImage.swiftLogo
        userImageView.layer.cornerRadius = userImageView.frame.size.width * 0.5
        if let userName: String = userName {
            userNameLabel.text = userName
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
