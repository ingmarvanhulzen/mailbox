//
//  Mail+CoreDataClass.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 27/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Mail)
public class Mail: NSManagedObject {
    
    func relativeDate() -> String {
        if let date = self.date {
            let dateFormatter = DateFormatter()
            let calendar = Calendar(identifier: .gregorian)
            dateFormatter.doesRelativeDateFormatting = true

            if calendar.isDateInToday(date) {
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .none
            } else if calendar.isDateInYesterday(date){
                dateFormatter.timeStyle = .none
                dateFormatter.dateStyle = .medium
            } else if calendar.compare(Date(), to: date, toGranularity: .weekOfYear) == .orderedSame {
                let weekday = calendar.dateComponents([.weekday], from: date).weekday ?? 0
                return dateFormatter.weekdaySymbols[weekday-1]
            } else {
                dateFormatter.timeStyle = .none
                dateFormatter.dateStyle = .short
            }

            return dateFormatter.string(from: date)
        }
        
        return ""
    }
    
    public class func fetchForMailbox(mailbox: Mailbox) -> NSFetchRequest<Mail> {
        let request = NSFetchRequest<Mail>(entityName: "Mail")
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: false)
             
        var predicate = NSPredicate(format: "removed == false")

        // Filter by mailbox if mailboxes issnt "All Inboxes"
        if mailbox.title != "All Inboxes" {
            predicate = NSPredicate(format: "removed == false && mailbox == %@", mailbox)
        }
        
        request.sortDescriptors = [sortDescriptors]
        request.predicate = predicate

        return request
    }
    
    public class func fetchForMailboxUnread(mailbox: Mailbox) -> NSFetchRequest<Mail> {
        let request = NSFetchRequest<Mail>(entityName: "Mail")
        
        var predicate = NSPredicate(format: "read == false && removed == false")

        // Filter by mailbox if mailboxes issnt "All Inboxes"
        if mailbox.title != "All Inboxes" {
            predicate = NSPredicate(format: "read == false && removed == false && mailbox == %@", mailbox)
        }
        
        request.predicate = predicate
        
        return request
    }
}
