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
    
    private let mailboxes: [Mailbox] = MockStore.shared.mailboxes

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.title = mailboxes[indexPath.row].title
                destination.listItems = mailboxes[indexPath.row].mails
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
        
        if let data = mailboxes[indexPath.row] as Mailbox? {
            cell.textLabel?.text = data.title
            cell.imageView?.image = data.image
            cell.detailTextLabel?.text = data.meta > 0 ? String(data.meta) : ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowListViewController", sender: self)
    }
}

