


import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    // Массивы для реализации таблицы, поиска
    
    var contacts: [Contacts] = []
    var searchResult: [Contacts] = []
    var fetchResultController: NSFetchedResultsController!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Реализуем поиск
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Поиск контактов..."
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.barTintColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        
        // Загружаем информацию из Core Data при запуске приложения
        
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        let sortDescriptor = NSSortDescriptor(key: "firstname", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                contacts = fetchResultController.fetchedObjects as! [Contacts]
            } catch {
                print(error)
            }
        }
        
        
        
        
        // Удалить title у кнопки  back
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        

        
        tableView.reloadData()
        
    }
    
    // Срабатывает при обращении к контроллеру
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        prefersStatusBarHidden()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // В таблице 1 секция
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Таблица заполняется из переменной contacts - > Core Data
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResult.count
        } else {
            return contacts.count
        }
    }
    
    // Настраиваем идентификатор ячейки и данные на экране
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        
        let contact = (searchController.active) ? searchResult[indexPath.row] : contacts[indexPath.row]
        
        // Настройка ячейки
        cell.nameLabel.text = contact.firstname
        cell.photoView.image = UIImage(data: contact.photo!)
        cell.lastName.text = contact.lastname
        cell.phoneNumberLabel.text = contact.phonenumber
       
        
        return cell
    }
    
    // При нажатии на ячейку возможность совершить головосой вызов
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contact = (searchController.active) ? searchResult[indexPath.row] : contacts[indexPath.row]
        
        let alertVC = UIAlertController(title: "Действие", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let callContact = UIAlertAction(title: "Позвонить", style: .Default) { (UIAlertAction) in
            
            let url:NSURL? = NSURL(string: "tel://\(contact.phonenumber)")
            UIApplication.sharedApplication().openURL(url!)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
        
        alertVC.addAction(callContact)
        alertVC.addAction(cancel)
        
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // Проверка поиска
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active {
            return false
        } else {
            return true
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    
    // Fetch Object
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let _newIndexPath = newIndexPath {
                tableView.deleteRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let _newIndexPath = newIndexPath {
                tableView.reloadRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        default:
            tableView.reloadData()
        }
        contacts = controller.fetchedObjects as! [Contacts]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
   
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
       
    
        
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Удалить", handler: {(actin, indexPath) -> Void in
            self.contacts.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let contactToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Contacts
                
                managedObjectContext.deleteObject(contactToDelete)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
            
        })
        
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        return [deleteAction]
    }
    



    // Обновление таблицы при использовании поиска
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(searchText)
            tableView.reloadData()
        }
    }
    
    // Фильтрация контента в таблице при поиске
    
    func filterContent(searchText: String) {
        searchResult = contacts.filter({ (contact: Contacts) -> Bool in
            let name1 = contact.firstname.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let name2 = contact.lastname.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            return name1 != nil || name2 != nil
        })
    }
    

}
