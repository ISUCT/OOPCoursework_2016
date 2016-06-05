

import UIKit
import CoreData

class addContactsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //*** Этот класс мы полностью настроили на запись/прием введенной информации. *** Первым делом добавим аутлеты для всех объектов взаимодействия
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var firstNameText: UITextField!

    @IBOutlet weak var lastNameText: UITextField!

    @IBOutlet weak var phoneNumberText: UITextField!
    
    
    // Переменная, которая хранит данные в Core Data
    var contacts: Contacts!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberText.keyboardType = .NumberPad // Клавиатура только цифровая
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Реализуем библиотеку фото для выбора аватара
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Выводим изображение из библиотеки на экран
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Реализуем кнопку сохранения контакта, записываем все данные в Core Data и выводим в ячейку
    @IBAction func save(sender:UIBarButtonItem) {
        let firstName = firstNameText.text
        let lastName = lastNameText.text
        let phoneNumber = phoneNumberText.text
        
       
        if firstName == "" || lastName == "" || phoneNumber == "" {
            let alertController = UIAlertController(title: "!", message: "ERROR", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            contacts = NSEntityDescription.insertNewObjectForEntityForName("Contacts", inManagedObjectContext: managedObjectContext) as! Contacts
            
            contacts.firstname = firstName!
            contacts.lastname = lastName!
            contacts.phonenumber = phoneNumber!
            if let photoImage = imageView.image {
                contacts.photo = UIImagePNGRepresentation(photoImage)
            }
           
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

