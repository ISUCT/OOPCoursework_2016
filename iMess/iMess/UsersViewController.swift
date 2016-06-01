//
//  UsersViewController.swift
//  iMess
//
//  Created by Дмитрий Александров on 12.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit
import Parse

var currentUserName = "" // глобальная переменная

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var userEmailsArray = [String]()
    var nicknamesArray = [String]()
    var imageFileArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserName = PFUser.currentUser()!.username!
        let predicate = NSPredicate(format: "username != %@", currentUserName)
        let query = PFQuery(className: "_User", predicate: predicate)
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            
            let users = objects as! [PFUser]
            
            for user in users {
                self.userEmailsArray.append(user.email!)
                self.nicknamesArray.append(user.username!)
                self.imageFileArray.append(user["image"] as! PFFile)
                self.tableView.reloadData()
                
            }
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Скроем кнопку назад после авторизиации/регистрации
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nicknamesArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UsersTableViewCell
        
        
        cell.emailLabel.text = userEmailsArray[indexPath.row]
        cell.loginLabel.text = nicknamesArray[indexPath.row]
        
        imageFileArray[indexPath.row].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            
            if error == nil {
                let image = UIImage(data: imageData!) // Извлекаем изображение
                cell.profileImageView.image = image
            }
        }
        
        
        return cell
    }
    
    // Высота нашей ячейки -> 100
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // Действие при нажатии на ячейку
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UsersTableViewCell
        
        // Получаем данные
        recipientEmail = cell.emailLabel.text!
        recipientNickname = cell.loginLabel.text!
        self.performSegueWithIdentifier("ChatSegue", sender: self)
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        
        PFUser.logOut() // Завершаем сеанс
        self.navigationController?.popToRootViewControllerAnimated(true) // После logout переводим на главный контроллер
    }
    
    
    
    
    
    
    
    
    
}
