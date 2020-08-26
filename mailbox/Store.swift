//
//  Store.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 25/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit


struct Mailbox: Identifiable, Decodable {
    let id: UUID
    let title: String!
    
    var meta: Int {
        get {
            return mails.filter({ $0.read == false }).count
        }
    }
    
    var mails: [Mail] {
        get {
            if title != "All Inboxes" {
                return MockStore.shared.mails.filter({ $0.mailbox == id })
            }
        
            return MockStore.shared.mails
        }
    }
    
    var image: UIImage! {
        get {
            if title != "All Inboxes" {
                return UIImage(systemName: "tray")
            }
            
            return UIImage(systemName: "tray.2")
        }
    }
}

struct Mail: Identifiable, Decodable {
    let id: UUID
    let mailbox: UUID
    let headline: String!
    let subHeadline: String!
    let content: String!
    let date: Date!
    let read: Bool!
}

func loadMailbox() -> [Mailbox] {
    let decoder = JSONDecoder()
    
    if let url = Bundle.main.url(forResource: "mock_mailboxs", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([Mailbox].self, from: data)
        } catch let error {
            print(error)
        }
    }
    
    return []
}

func loadMail() -> [Mail] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    if let url = Bundle.main.url(forResource: "mock_mail", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([Mail].self, from: data)
        } catch let error {
            print(error)
        }
    }
    
    return []
}

struct MockStore {
    static let shared = MockStore()
    
    let mailboxes: [Mailbox]
    let mails: [Mail]
    
    init() {
        mails = loadMail()
        mailboxes = loadMailbox()
    }
}
