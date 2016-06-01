//
//  ChatViewController.swift
//  iMess
//
//  Created by Дмитрий Александров on 12.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit
import Parse

import UIKit
import Parse

var recipientEmail = ""
var recipientNickname = ""

class ChatViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var chatScrollView: UIScrollView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var blockUnblockButton: UIBarButtonItem!
    
    var isBlocked = false
    
    var messageArray = [String]()
    var senderArray = [String]()
    
    var currentUserImage: UIImage?
    var recipientImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.addSubview(promptLabel)
        self.title = recipientNickname
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.didTapScrollView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        chatScrollView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapUpdateChat = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.updateChats))
        tapUpdateChat.numberOfTapsRequired = 2
        chatScrollView.addGestureRecognizer(tapUpdateChat)
        
    }
    
    func updateChats() {
        
        updateChat()
    }
    
    func didTapScrollView(){
        self.view.endEditing(true)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        let dict: NSDictionary = notification.userInfo!
        let keyboardSize: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let frameKeyboardSize: CGRect = keyboardSize.CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.chatScrollView.frame.size.height -= frameKeyboardSize.height
            self.messageView.frame.origin.y -= frameKeyboardSize.height
            
            let scrollViewOffset: CGPoint = CGPointMake(0, self.chatScrollView.contentSize.height - self.chatScrollView.bounds.size.height)
            self.chatScrollView.setContentOffset(scrollViewOffset, animated: true)
            
            }) { (finished: Bool) -> Void in
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let dict: NSDictionary = notification.userInfo!
        let keyboardSize: NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let frameKeyboardSize: CGRect = keyboardSize.CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.chatScrollView.frame.size.height += frameKeyboardSize.height
            self.messageView.frame.origin.y += frameKeyboardSize.height
            
            }) { (finished: Bool) -> Void in
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.promptLabel.hidden = messageTextView.hasText() ? true : false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !self.messageTextView.hasText() {
            self.promptLabel.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isBlockedPredicate = NSPredicate(format: "user == %@ || blockUser == %@", recipientNickname, currentUserName)
        
        let isBlockedQuery = PFQuery(className: "Block", predicate: isBlockedPredicate)
        
        isBlockedQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            if objects?.count > 0 {
                
                self.isBlocked = true
                
            } else {
                
                self.isBlocked = false
            }
        }
        
        // Фильтр
        let blockPredicate = NSPredicate(format: "user == %@ || blockUser == %@", currentUserName, recipientNickname)
        
        let blockQuery = PFQuery(className: "Block", predicate: blockPredicate)
        
        blockQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            
            self.blockUnblockButton.title = !objects!.isEmpty ? "Разблок." : "Блок"
        }
        
        var userImageArray = [PFFile]()
        
        let queryForCurrentUser = PFQuery(className: "_User")
        queryForCurrentUser.whereKey("username", equalTo: currentUserName)
        
        queryForCurrentUser.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            for object in objects! {
                userImageArray.append(object["image"] as! PFFile)
                userImageArray.first?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        self.currentUserImage = UIImage(data: imageData!)
                        userImageArray.removeAll(keepCapacity: false)
                    }
                })
            }
            
            let queryForRecipient = PFQuery(className: "_User")
            queryForRecipient.whereKey("username", equalTo: recipientNickname)
            
            queryForRecipient.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                
                for object in objects! {
                    userImageArray.append(object["image"] as! PFFile)
                    userImageArray.first?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            self.recipientImage = UIImage(data: imageData!)
                            userImageArray.removeAll(keepCapacity: false)
                        }
                    })
                }
                
            }
            self.updateChat()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateChat(){
        let messageMarginX: CGFloat = 58 // для отступов текста
        var messageMarginY: CGFloat = 14
        
        let bubbleMarginX: CGFloat = 55 // Отступы для облака, внутри которого находится текст сообщения
        var bubbleMarginY: CGFloat = 8
        
        let imageMarginX: CGFloat = 15 // Отступы для изображения
        var imageMarginY: CGFloat = 5
        
        messageArray.removeAll(keepCapacity: false)
        senderArray.removeAll(keepCapacity: false)
        
        let predicate1 = NSPredicate(format: "sender = %@ AND recipient = %@", currentUserName, recipientNickname)
        let predicate2 = NSPredicate(format: "sender = %@ AND recipient = %@", recipientNickname, currentUserName)
        
        let query1 = PFQuery(className: "Message", predicate: predicate1)
        let query2 = PFQuery(className: "Message", predicate: predicate2)
        
        let resultQuery = PFQuery.orQueryWithSubqueries([query1, query2])
        resultQuery.addAscendingOrder("createdAt")
        
        resultQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    self.senderArray.append(object.objectForKey("sender") as! String)
                    self.messageArray.append(object.objectForKey("message") as! String)
                }
                
                for i in 0..<self.messageArray.count {
                    if self.senderArray[i] == currentUserName {
                        
                        let messageLabel = UILabel()
                        messageLabel.text = self.messageArray[i]
                        messageLabel.frame = CGRectMake(0, 0, self.chatScrollView.frame.size.width - 90, CGFloat.max)
                        messageLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
                        
                        messageLabel.numberOfLines = 0
                        messageLabel.lineBreakMode = .ByWordWrapping
                        messageLabel.sizeToFit()
                        
                        messageLabel.textAlignment = .Left
                        messageLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 16)
                        messageLabel.textColor = UIColor.blackColor()
                        
                        messageLabel.frame.origin.x = self.chatScrollView.frame.size.width - messageLabel.frame.size.width - messageMarginX
                        messageLabel.frame.origin.y = messageMarginY
                        messageMarginY += messageLabel.frame.size.height + 30
                        self.chatScrollView.addSubview(messageLabel)
                        
                        
                        let bubbleLabel = UILabel()
                        bubbleLabel.frame.size = CGSizeMake(messageLabel.frame.size.width + 10, messageLabel.frame.size.height + 10)
                        bubbleLabel.frame.origin.x = self.chatScrollView.frame.size.width - bubbleLabel.frame.size.width - bubbleMarginX
                        bubbleLabel.frame.origin.y = bubbleMarginY
                        bubbleMarginY += bubbleLabel.frame.size.height + 20
                        bubbleLabel.layer.cornerRadius = 10
                        bubbleLabel.clipsToBounds = true
                        bubbleLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
                        
                        self.chatScrollView.addSubview(bubbleLabel)
                        
                        let width = self.view.frame.size.width
                        self.chatScrollView.contentSize = CGSizeMake(width, messageMarginY)
                        self.chatScrollView.bringSubviewToFront(messageLabel)
                        
                        
                        let senderImage = UIImageView()
                        senderImage.image = self.currentUserImage
                        senderImage.frame.size = CGSize(width: 35, height: 35)
                        senderImage.frame.origin = CGPoint(x: self.chatScrollView.frame.size.width - senderImage.frame.size.width - imageMarginX, y: imageMarginY)
                        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
                        senderImage.clipsToBounds = true
                        self.chatScrollView.addSubview(senderImage)
                        
                        imageMarginY += bubbleLabel.frame.size.height + 20
                        self.chatScrollView.bringSubviewToFront(senderImage)
                        
                        
                    } else {
                        
                        let messageLabel = UILabel()
                        messageLabel.text = self.messageArray[i]
                        messageLabel.frame = CGRectMake(0, 0, self.chatScrollView.frame.size.width - 90, CGFloat.max)
                        messageLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
                        
                        messageLabel.numberOfLines = 0
                        messageLabel.lineBreakMode = .ByWordWrapping
                        messageLabel.sizeToFit()
                        
                        messageLabel.textAlignment = .Left
                        messageLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 16)
                        messageLabel.textColor = UIColor.blackColor()
                        
                        messageLabel.frame.origin.x = messageMarginX
                        messageLabel.frame.origin.y = messageMarginY
                        messageMarginY += messageLabel.frame.size.height + 30
                        self.chatScrollView.addSubview(messageLabel)
                        
                        let bubbleLabel = UILabel()
                        bubbleLabel.frame = CGRectMake(bubbleMarginX, bubbleMarginY, messageLabel.frame.size.width + 10, messageLabel.frame.size.height + 10)
                        bubbleMarginY += bubbleLabel.frame.size.height + 20
                        bubbleLabel.layer.cornerRadius = 10
                        bubbleLabel.clipsToBounds = true
                        bubbleLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
                        
                        self.chatScrollView.addSubview(bubbleLabel)
                        
                        let width = self.view.frame.size.width
                        self.chatScrollView.contentSize = CGSizeMake(width, messageMarginY)
                        self.chatScrollView.bringSubviewToFront(messageLabel)
                        
                        let senderImage = UIImageView()
                        senderImage.image = self.recipientImage
                        senderImage.frame = CGRectMake(imageMarginX, imageMarginY, 35, 35)
                        senderImage.layer.cornerRadius = senderImage.frame.size.width / 2
                        senderImage.clipsToBounds = true
                        self.chatScrollView.addSubview(senderImage)
                        
                        imageMarginY += bubbleLabel.frame.size.height + 20
                        self.chatScrollView.bringSubviewToFront(senderImage)
                    }
                    
                    let scrollViewOffset: CGPoint = CGPointMake(0, self.chatScrollView.contentSize.height - self.chatScrollView.bounds.size.height)
                    self.chatScrollView.setContentOffset(scrollViewOffset, animated: true)
                }
            }
        }
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        if isBlocked {
            
            let blockedAlertController = UIAlertController(title: "Ошибка", message: "\(recipientNickname) заблокировал вас", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            blockedAlertController.addAction(okAction)
            
            presentViewController(blockedAlertController, animated: true, completion: nil)
            
            return
        }
        
        didTapScrollView()
        
        if messageTextView.text.isEmpty {
            print("no text in the message")
        } else {
            
            let messageDB = PFObject(className: "Message")
            messageDB["sender"] = currentUserName
            messageDB["recipient"] = recipientNickname
            messageDB["message"] = self.messageTextView.text
            
            messageDB.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("message saved")
                    self.messageTextView.text = ""
                    self.promptLabel.hidden = false
                    self.updateChat()
                } else {
                    print("message not saved because of error: \(error?.localizedDescription)")
                }
            })
        }
    }
    
    @IBAction func blockUnblockButtonPressed(sender: UIBarButtonItem) {
        
        if blockUnblockButton.title == "Блок" {
           blockUnblockButton.title = "Разблок."
            
            let addBlockUser = PFObject(className: "Block")
            addBlockUser.setObject(currentUserName, forKey: "user")
            addBlockUser.setObject(recipientNickname, forKey: "blockUser")
            addBlockUser.saveInBackground()
        } else {
            
            blockUnblockButton.title = "Блок"
            
            let blockUserPredicate = NSPredicate(format: "user == %@ || blockUser == %@", currentUserName, recipientNickname)
            let blockUserQuery = PFQuery(className: "Block", predicate: blockUserPredicate)
            
            blockUserQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                
                for object in objects! {
                    
                    object.deleteInBackground()
                }
            })
        }
    }
   
    @IBAction func reportButtonPressed(sender: AnyObject) {
        
        let addReportObject = PFObject(className: "Report")
        addReportObject.setObject(currentUserName, forKey: "user")
        addReportObject.setObject(recipientNickname, forKey: "reportedUser")
        addReportObject.saveInBackgroundWithBlock { (completed: Bool, error: NSError?) -> Void in
            
            if completed {
                
                let alertVC = UIAlertController(title: "Жалоба отправлена", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alertVC.addAction(okAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
                
            } else {
                
                let alertVC = UIAlertController(title: "Ошибка", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alertVC.addAction(okAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
                
                
            }
        }
    }
}










