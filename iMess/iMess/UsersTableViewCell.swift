//
//  UsersTableViewCell.swift
//  iMess
//
//  Created by Дмитрий Александров on 12.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Находим высоту
        let screenWidth = UIScreen.mainScreen().bounds.width
        contentView.frame = CGRectMake(0, 0, screenWidth, 100)
        
        profileImageView.center = CGPointMake(50, 50) // Середина картинки
        profileImageView.layer.cornerRadius = 40 // Округляем края изображения
        profileImageView.clipsToBounds = true // Для возможности округлить края
        loginLabel.center = CGPointMake(120, 50)
        loginLabel.textAlignment = .Left // Выровняли текст по левому краю
        loginLabel.bounds.size.width = screenWidth / 2
        emailLabel.center = CGPointMake(120, 50)
        emailLabel.textAlignment = .Left
        emailLabel.bounds.size.width = screenWidth / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
