//
//  SignUpViewController.swift
//  iMess
//
//  Created by Дмитрий Александров on 09.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 47.5
        imageView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Скрываем клавиатуру при нажатии на Return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        loginTextField.resignFirstResponder()
        return true
    }
    
    // Скрываем клавиатуру при тапе в случайном месте View
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Поднимаем View при открытии клавиатуры
    func textFieldDidBeginEditing(textField: UITextField) {
        let mainViewHeight = self.view.bounds.size.height // Высота
        let mainViewWidth = self.view.bounds.size.width // Ширина
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: { () -> Void in
            if UIScreen.mainScreen().bounds.height > 468 {
                self.view.center = CGPoint(x: mainViewWidth / 2, y: mainViewHeight / 2 - 50)
            }
            }, completion: nil)
    }
    
    // Возвращаем View на место при скрытии клавиатуры
    func textFieldDidEndEditing(textField: UITextField) {
        let mainViewHeight = self.view.bounds.size.height // Высота
        let mainViewWidth = self.view.bounds.size.width // Ширина
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: { () -> Void in
            if UIScreen.mainScreen().bounds.height > 468 {
                self.view.center = CGPoint(x: mainViewWidth / 2, y: mainViewHeight / 2)
            }
            }, completion: nil)
    }
    
    
    
    
    
    
    @IBAction func addImageButtonPressed(sender: AnyObject) {
        
        // Реализуем возможность установить фото
        
        let photoAction = UIAlertController(title: "Выберите фото", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let choosePhoto = UIAlertAction(title: "Выбрать фото из галлереи", style: UIAlertActionStyle.Default) { (UIAlertAction) in
           
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary // Возможность выбрать фото из галлереи
            image.allowsEditing = true // Возможность обрезать фото
            self.presentViewController(image, animated: true, completion: nil)

        }
        
        let takePhoto = UIAlertAction(title: "Сделать фото", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .Camera
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel, handler: nil)
        
        photoAction.addAction(choosePhoto)
        photoAction.addAction(takePhoto)
        photoAction.addAction(cancel)
        self.presentViewController(photoAction, animated: true, completion: nil)
    }
    
    // Отображаем выбранное фото на imageView
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Регистрация пользователя
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        let user = PFUser()
        user.username = loginTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        let imageData = UIImagePNGRepresentation(self.imageView.image!)
        let imageFile = PFFile(name: "profileImage.png", data: imageData!)
        user["image"] = imageFile
        
        
        
        user.signUpInBackgroundWithBlock({ (complete: Bool, error: NSError?) -> Void in
            if error == nil {
                self.performSegueWithIdentifier("toUsersSegue2", sender: self)
            } else {
                return
            }
        })
        
    }
    
    
}









