//
//  ViewController.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 24/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier);

        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    
    private let reuseIdentifier = "ViewControllerCell"
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()

    private var mailboxes = [Mailbox]()
    
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mailboxes"
        view.backgroundColor = .systemGroupedBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ViewControllerCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.addSubview(tableView)
        
        navigationController?.isToolbarHidden = false
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(presentNew))
        ]
        
        initializeStore(context: self.context)
        
        self.fetchMailboxes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchMailboxes()
    }
    
    override func updateViewConstraints() {
        NSLayoutConstraint.activate([
           tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
           tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
           tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
           tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        super.updateViewConstraints()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.title = mailboxes[indexPath.row].title
                destination.mailbox = mailboxes[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailboxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ViewControllerCell
        
        let mailbox = mailboxes[indexPath.row]
        let count = self.fetchUnreadCountForMailbox(mailbox: mailbox)
        
        cell.textLabel?.text = mailbox.title
        cell.imageView?.image = mailbox.image
        cell.detailTextLabel?.text = count > 0 ? String(count) : ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowListViewController", sender: self)
    }
}

extension ViewController {
    
    // Method to fetch the mailboxes from CoreData
    // Action: reloads tableView with fetched result
    private func fetchMailboxes() {
        
        do {
            let request = Mailbox.fetchRequest() as NSFetchRequest
            let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
            
            request.sortDescriptors = [sortDescriptors]
            
            self.mailboxes = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {}
    }
    
    // Method to fetch the unread count for a specific mailbox from CoreData
    // Return: specific mailbox unread count
    private func fetchUnreadCountForMailbox(mailbox: Mailbox) -> Int {
        do {
            return try self.context.fetch(Mail.fetchForMailboxUnread(mailbox: mailbox)).count
        } catch {
            return 0
        }
    }
    
    @objc func presentNew() {
        performSegue(withIdentifier: "ShowNewViewController", sender: self)
    }
}
