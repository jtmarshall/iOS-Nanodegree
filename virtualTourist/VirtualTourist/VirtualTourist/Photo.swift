//
//  Photo.swift
//  VirtualTourist
//
//  Created by Jordan  on 7/10/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(pin: Pin,/*imageData: NSData,*/ imageURL: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all the information you provided in the Entity part of the model. You need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            // Calling designated initializer
            self.init(entity: ent, insertInto: context)
            self.pin = pin
            // self.imageData = imageData
            self.imageURL = imageURL
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var pin: Pin?
    
}
