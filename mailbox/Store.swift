//
//  Store.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 25/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit
import CoreData


func initializeStore(context: NSManagedObjectContext) {
    var mailboxes = [String: Mailbox]()
    
    if let url = Bundle.main.url(forResource: "mock_mailboxs", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let fetchData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! NSArray
            
            for eachData in fetchData {
                let eachdataitem = eachData as! [String : String]
                let mailbox = Mailbox(context: context)
                let mailboxId = eachdataitem["id"]!

                mailbox.title = eachdataitem["title"]
                mailbox.date = Date()
                
                mailboxes[mailboxId] = mailbox
            }
        } catch let error {
            print(error)
        }
    }
    
    if let url = Bundle.main.url(forResource: "mock_mail", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let fetchData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! NSArray
            let dateFormatter = ISO8601DateFormatter()
            
            var timeBetween = TimeInterval.nan
            
            for eachData in fetchData {
                let eachdataitem = eachData as! [String : Any]
                let mail = Mail(context: context)
                let date = dateFormatter.date(from: eachdataitem["date"] as! String)
                let mailboxId = eachdataitem["mailbox"] as! String

                if timeBetween.isNaN {
                    timeBetween = Date().timeIntervalSince(date!)
                }
                
                mail.headline = eachdataitem["headline"] as? String
                mail.subHeadline = eachdataitem["subHeadline"] as? String
                mail.content = eachdataitem["content"] as? String
                mail.read = eachdataitem["read"] as! Bool
                mail.date = date?.addingTimeInterval(timeBetween)
                mail.mailbox = mailboxes[mailboxId]
                mail.removed = false
            }
            
        } catch let error {
            print(error)
        }
    }
}
