//
//  ChatsCell.swift
//  iMess
//
//  Created by Дмитрий Александров on 23.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit
import Parse

class ChatsCell: UITableViewCell {
    

    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
