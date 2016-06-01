//
//  ChatsTableViewController.swift
//  iMess
//
//  Created by Дмитрий Александров on 23.03.16.
//  Copyright © 2016 Дмитрий Александров. All rights reserved.
//

import UIKit
import Parse

class ChatsTableViewController: UITableViewController {
    
    var senderArray = [String]()
    var recipientArray = [String]()
    var messageArray = [String]()
    var namesArray = [String]()
    var messagesArray = [String]()
    
    var imageFilesArray: [PFFile?]?
    var imagesArray: [UIImage?]?
    
    override func viewDidLoad() {
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        senderArray.removeAll(keepCapacity: false)
        recipientArray.removeAll(keepCapacity: false)
        messageArray.removeAll(keepCapacity: false)
        namesArray.removeAll(keepCapacity: false)
        messagesArray.removeAll(keepCapacity: false)
        
        let chatsPredicate = NSPredicate(format: "sender == %@ || recipient == %@", currentUserName, currentUserName)
        let chatsQuery = PFQuery(className: "Message", predicate: chatsPredicate)
        chatsQuery.addDescendingOrder("createdAt")
        chatsQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    self.senderArray.append(object.objectForKey("sender") as! String)
                    self.recipientArray.append(object.objectForKey("recipient") as! String)
                    self.messageArray.append(object.objectForKey("message") as! String)
                }
                
                for i in 0 ..< self.senderArray.count {
                    if self.senderArray[i] != currentUserName {
                        self.namesArray.append(self.senderArray[i])
                        self.messagesArray.append(self.messageArray[i])
                    } else {
                        self.namesArray.append(self.recipientArray[i])
                        self.messagesArray.append(self.messageArray[i])
                    }
                }
                
                for i in 0 ..< self.namesArray.count {
                
                    
                    var j = i + 1
                    while j < self.namesArray.count {
                        if self.namesArray[i] == self.namesArray[j] {
                            self.namesArray.removeAtIndex(j)
                            self.messagesArray.removeAtIndex(j)
                            j -= 1
                        }
                        j += 1
                    }
                }
                
                self.imagesArray = [UIImage?](count: self.namesArray.count, repeatedValue: nil)
                self.imageFilesArray = [PFFile?](count: self.namesArray.count, repeatedValue: nil)
                self.fetchData()
            } else {
                print("error: \(error?.localizedDescription)")
            }
        }
    }
    
    
    func fetchData() {
        
        for index in 0...self.namesArray.count - 1 {
            
            let imagePredicate = NSPredicate(format: "username == %@", namesArray[index])
            let imageQuery = PFQuery(className: "_User", predicate: imagePredicate)
            
            imageQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    for object in objects! {
                        self.imageFilesArray![index] = object["image"] as? PFFile
                    }
                    
                    for imageFile in self.imageFilesArray! {
                        let index = self.imageFilesArray?.indexOf{$0 == imageFile}
                        imageFile?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                            let userImage = UIImage(data: imageData!)
                            self.imagesArray?[index!] = userImage
                            self.tableView.reloadData()
                        })
                    }
                }
            })
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesArray.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ChatsCell
        
        cell.nameLabel.text = namesArray[indexPath.row]
        cell.messageTextLabel.text = messagesArray[indexPath.row]
        cell.chatImageView.image = self.imagesArray![indexPath.row] != nil ? self.imagesArray![indexPath.row] : UIImage(named: "add")
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChatsCell
        recipientNickname = cell.nameLabel.text!
        self.performSegueWithIdentifier("ChatSegue2", sender: self)
    }
    
    
    
}


            
        

