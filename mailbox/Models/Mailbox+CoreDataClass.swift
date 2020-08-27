//
//  Mailbox+CoreDataClass.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 27/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Mailbox)
public class Mailbox: NSManagedObject {

    var image: UIImage {
        get {
            if self.title != "All Inboxes" {
                return UIImage(systemName: "tray")!
            }
            
            return UIImage(systemName: "tray.2")!
        }
    }
}
