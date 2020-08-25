//
//  ViewController.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 24/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit

struct ViewControllerCellData {
    let title: String!
    let image: UIImage!
    let count: Int!
}

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
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    private let mailboxes: [ViewControllerCellData] = [
        .init(title: "All Inboxes", image: UIImage(systemName: "tray.2"), count: 24),
        .init(title: "Outlook", image: UIImage(systemName: "tray"), count: 12),
        .init(title: "G mail", image: UIImage(systemName: "tray"), count: 0),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mailboxes"
        view.backgroundColor = .systemGroupedBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ViewControllerCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.addSubview(tableView)
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
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailboxes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ViewControllerCell
        
        if let data = mailboxes[indexPath.row] as ViewControllerCellData? {
            cell.textLabel?.text = data.title
            cell.imageView?.image = data.image
            cell.detailTextLabel?.text = data.count ?? 0 > 0 ? String(data.count) : ""
        }
        
        return cell
    }
}

