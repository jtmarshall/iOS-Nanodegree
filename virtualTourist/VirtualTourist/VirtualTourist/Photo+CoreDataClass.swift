//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Jordan  on 7/10/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import CoreData

public class Photo: NSManagedObject {

    convenience init(pin: Pin, imageURL: String, context: NSManagedObjectContext) {
        
        // Object that has access to all info provided in the "entities" of model, need it to create an instance
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            // initializer
            self.init(entity: ent, insertInto: context)
            self.pin = pin
            self.imageURL = imageURL
        } else {
            fatalError("Can't get entity name.")
        }
    }

}
