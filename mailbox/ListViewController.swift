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
    
    var readIndicator: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "circle.fill"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
     }()
    
    var disclosureIndicator: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.right"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .secondaryLabel
        return view
    }()
    
    var flagIndicator: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "flag.fill"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .none
        
        self.addSubviews()
        self.addSubviewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(readIndicator)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(disclosureIndicator)
        contentView.addSubview(flagIndicator)
    }
    
    private func addSubviewConstraints() {
        let viewsDict = [
            "read": readIndicator,
            "subject": subjectLabel,
            "subTitle": subTitleLabel,
            "content": contentLabel,
            "date": dateLabel,
            "disclosure": disclosureIndicator,
            "flag": flagIndicator,
        ]
        
        let constraints = [
            "H:|-6-[read(14)]-6-[subject]-[date]-[disclosure(10)]-6-|",
            "H:|-26-[subTitle]-[flag(10)]-6-|",
            "H:|-26-[content]-16-|",
            "V:|-[read][subTitle][content]-|",
            "V:|-[subject][subTitle][content]-|",
            "V:|-[date][subTitle][content]-|",
            "V:|-[disclosure][subTitle][content]-|",
            "V:|-[disclosure][flag][content]-|",
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

    private var showUnread = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListViewControllerCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        view.setNeedsUpdateConstraints()
        view.addSubview(tableView)
        
        toolbarItems = [
            UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(toggleShowUnread)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(customView: self.showUnreadTabBarView()),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(presentNew))
        ]
        
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
            cell.readIndicator.tintColor = mail.read ? .clear : .systemBlue
            cell.flagIndicator.tintColor = mail.flag ? .systemOrange : .clear
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            deleteContextualAction(forRowAt: indexPath),
            toggleFlagContextualAction(forRowAt: indexPath)
        ])
    }
}

extension ListViewController {
    
    // Method to fetch the mails for a specific mailbox from CoreData
    // Action: reloads tableView with fetched result
    private func fetchMails() {
        do {
            self.listItems = try context.fetch(showUnread ? Mail.fetchForMailboxUnread(mailbox: self.mailbox!) : Mail.fetchForMailbox(mailbox: self.mailbox!))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTabBarItems()
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
            cell.readIndicator.tintColor = tintColor
            self.updateTabBarItems()
            
            completion(true)
        }
        
        action.backgroundColor = .systemBlue
        action.image = image
        return action
    }
    
    // Method to create the delete action for a specific row
    // Return: specific row delete action
    private func deleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let mail = self.listItems[indexPath.row]
    
        let action = UIContextualAction(style: .destructive, title: "Trash") { (_, _, completion) in
            mail.removed = true
            
            self.listItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .top)
            self.updateTabBarItems()
            
            completion(true)
        }
       
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "trash.fill")
        return action
    }
    
    // Method to create the toggle flag action for a specific row
    // Return: specific row toggle flag action
    private func toggleFlagContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let mail = self.listItems[indexPath.row]
        
        let (title, tintColor, image) = mail.flag ?
            ("Unflag", UIColor.clear, UIImage(systemName: "flag.slash.fill")) :
            ("Flag", UIColor.systemOrange, UIImage(systemName: "flag.fill"))
        
        let action = UIContextualAction(style: .normal, title: title) { (_, _, completion) in
            mail.flag.toggle()
            
            let cell = self.tableView.cellForRow(at: indexPath) as! ListViewControllerCell
            cell.flagIndicator.tintColor = tintColor
            
            completion(true)
        }
        
        action.backgroundColor = .systemOrange
        action.image = image
        return action
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
    
    private func showUnreadTabBarView() -> UIView {
        let view = UIView()
        
        let label = UILabel()
        label.text = "Updated Just Now"
        label.font = .preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        let label2 = UILabel()
        label2.text = "Unread"
        label2.font = .preferredFont(forTextStyle: .caption2)
        label2.textColor = .systemBlue
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.textAlignment = .center
        
        let unreadCount = self.fetchUnreadCountForMailbox(mailbox: self.mailbox!)
        var constraints = ["V:|-[label]-|", "H:|-[label]-|"]
        var viewsDict = ["label": label]
                
        if showUnread || unreadCount > 0 {
            constraints = ["V:|-[label]-4-[label2]-|", "H:|-[label]-|", "H:|-[label2]-|"]
            viewsDict = ["label": label, "label2": label2]
            
            if showUnread {
                label.text = "Filtered by:"

            } else {
                if unreadCount > 0 {
                    label2.textColor = .secondaryLabel
                    label2.text = "\(unreadCount) Unread"
                }
            }
            
            view.addSubview(label)
            view.addSubview(label2)
        } else {
            view.addSubview(label)
        }
        
        for withVisualFormat in constraints {
            view.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: withVisualFormat, options: [], metrics: nil, views: viewsDict)
            )
        }
        
        return view
    }
    
    private func updateTabBarItems() {
        toolbarItems![0].image = UIImage(systemName: "line.horizontal.3.decrease.circle\(showUnread ? ".fill" : "")")
        toolbarItems![2].customView = self.showUnreadTabBarView()
    }
    
    @objc func toggleShowUnread(sender: UIBarButtonItem) {
        showUnread.toggle()
        
        self.fetchMails()
    }
    
    @objc func presentNew() {
        performSegue(withIdentifier: "ShowNewViewController", sender: self)
    }
}
