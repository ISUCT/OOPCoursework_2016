

import UIKit

class TableViewCell: UITableViewCell {
    
    // Привязываем объекты интерфейса в код
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var lastName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Скругляем изображение
        
        photoView.layer.cornerRadius = 30
        photoView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    }

}
