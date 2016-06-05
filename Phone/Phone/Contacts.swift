

import Foundation
import CoreData

// Класс, созданный Core Data, записывает и хранит данные

class Contacts: NSManagedObject {

    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var phonenumber: String
    @NSManaged var photo: NSData?

}
