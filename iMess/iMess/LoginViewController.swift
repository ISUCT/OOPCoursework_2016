//
//  LoginViewController.swift
//  iMess
//
//  Created by Дмитрий Александров on 09.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var loginTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var createdAccount: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.textAlignment = .Center
        passwordTextField.textAlignment = .Center
        
       
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground")!)
        
        
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        createdAccount.frame = CGRectMake(100, 100, 200, 40)
        createdAccount.setTitle("Создать аккаунт", forState: UIControlState.Normal)
        createdAccount.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        createdAccount.backgroundColor = UIColor.clearColor()
        createdAccount.layer.borderWidth = 1.0
        createdAccount.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        createdAccount.layer.cornerRadius = cornerRadius
        
        loginButton.frame = CGRectMake(100, 100, 200, 40)
        loginButton.setTitle("Вход", forState: UIControlState.Normal)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        loginButton.layer.cornerRadius = cornerRadius
        
     
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        didTapView()
        
        if loginTextField.text == "" || passwordTextField.text == "" || (loginTextField.text == "" && passwordTextField.text == "") {
            SCLAlertView().showTitle(
                "",
                subTitle: "Необходимо заполнить все данные",
                duration: 0.0,
                completeText: "Закрыть",
                style: .Notice,
                colorStyle: 202020,
                colorTextButton: 0xFFFFFF
            )
            loginTextField.text = ""
            passwordTextField.text = ""
            
        } else {
            
            PFUser.logInWithUsernameInBackground(loginTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                guard error == nil else {
                    
                    SCLAlertView().showTitle(
                        "Ошибка",
                        subTitle: "Неправильный логин или пароль",
                        duration: 0.0,
                        completeText: "Закрыть",
                        style: .Error,
                        colorStyle: 202020,
                        colorTextButton: 0xFFFFFF
                        )
                    
                    self.loginTextField.text = ""
                    self.passwordTextField.text = ""
                    return
                    
                }
                
                self.performSegueWithIdentifier("toUsersSegue1", sender: self) // Переход в окно контактов после авторизации
            }
            
            loginTextField.text = ""
            passwordTextField.text = ""
        }

            
        }
        

        
        
        
        
    @IBAction func createAccButtonPressed(sender: AnyObject) {
        
       
    }


}
