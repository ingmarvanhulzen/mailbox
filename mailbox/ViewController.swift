//
//  ViewController.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 24/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit

class ViewControllerCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.allowsSelection = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tableHeaderView = UIView(frame: .zero)
        view.tableFooterView = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    private let mailboxes = [
        "All Inboxes",
        "Outlook",
        "G-mail",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Mailboxes"
        view.backgroundColor = .secondarySystemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ViewControllerCell.self, forCellReuseIdentifier: "ViewControllerCell")
        
        view.addSubview(tableView)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        NSLayoutConstraint.activate([
           tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
           tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
           tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
           tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
       ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailboxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewControllerCell", for: indexPath)
        cell.textLabel?.text = mailboxes[indexPath.row]
        return cell
    }
}

