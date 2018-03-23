import UIKit
import Firebase

class ListItem: NSObject {
    var path: String
    var text: String
    var ref: DatabaseReference!
    init(text: String, path: String) {
        self.text = text
        self.path = path
        ref = Database.database().reference()
    }
    func update(){
        var childUpdates = [AnyHashable : Any]()
        if (Double(self.text) != nil){
            childUpdates = ["\(self.path)": Double(self.text)!]
        } else {
            childUpdates = ["\(self.path)": self.text]
        }
        ref.updateChildValues(childUpdates)
    }
}
