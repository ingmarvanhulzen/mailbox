//
//  ListViewController.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 25/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit


class ListViewControllerCell: UITableViewCell {
    
    var subjectLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    var indicator: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "circle.fill"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
     }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        
        self.addSubviews()
        self.addSubviewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(indicator)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
    }
    
    private func addSubviewConstraints() {
        let viewsDict = [
            "indicator": indicator,
            "subject": subjectLabel,
            "subTitle": subTitleLabel,
            "content": contentLabel,
            "date": dateLabel
        ]
        
        let constraints = [
            "H:|-6-[indicator(14)]-6-[subject]-[date]-|",
            "H:|-6-[indicator(14)]-6-[content]-|",
            "H:|-6-[indicator(14)]-6-[subTitle]-|",
            "V:|-[subject][subTitle][content]-|",
            "V:|-[date][subTitle][content]-|",
            "V:|-[indicator][subTitle][content]-|",
        ]
        
        constraints.forEach({
            contentView.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: viewsDict)
            )
        })
    }
}

class ListViewController: UIViewController {
    var mailbox: Mailbox?
    
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var listItems: [Mail] = []
    
    private let reuseIdentifier = "ListViewControllerCell"
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 80
        tableView.separatorInset.left = 26
        return tableView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListViewControllerCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.setNeedsUpdateConstraints()
        view.addSubview(tableView)
        
        self.fetchMails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.layoutMargins.left = tableView.separatorInset.left
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.layoutMargins.left = 20
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

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListViewControllerCell
                
        if let mail = listItems[indexPath.row] as Mail? {
            cell.subjectLabel.text = mail.headline
            cell.subTitleLabel.text = mail.subHeadline
            cell.contentLabel.text = mail.content
            cell.dateLabel.text = mail.relativeDate()
            cell.indicator.tintColor = mail.read ? .clear : .systemBlue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            toggleReadContextualAction(forRowAt: indexPath)
        ])
    }
    
    
}

extension ListViewController {
    
    // Method to fetch the mails for a specific mailbox from CoreData
    // Action: reloads tableView with fetched result
    private func fetchMails() {
        do {
            self.listItems = try context.fetch(Mail.fetchForMailbox(mailbox: self.mailbox!))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {}
    }

    // Method to create the toggle read action for a specific row
    // Return: specific row toggle read action
    private func toggleReadContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let mail = self.listItems[indexPath.row]
        
        let (title, tintColor, image) = mail.read ?
            ("Unread", UIColor.systemBlue, UIImage(systemName: "envelope.badge.fill")) :
            ("Read", UIColor.clear, UIImage(systemName: "envelope.open.fill"))
        
        let action = UIContextualAction(style: .normal, title: title) { (_, _, completion) in
            mail.read.toggle()
            
            let cell = self.tableView.cellForRow(at: indexPath) as! ListViewControllerCell
            cell.indicator.tintColor = tintColor
            
            completion(true)
        }
        
        action.backgroundColor = .systemBlue
        action.image = image
        return action
    }
}
