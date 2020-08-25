//
//  ListViewController.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 25/08/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit


extension Date {

    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self){
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday-1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }

        return dateFormatter.string(from: self)
    }
}

struct ListViewControllerCellData {
    let subject: String!
    let subTitle: String!
    let content: String!
    let date: Date!
    let read: Bool?
}

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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(subjectLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)

        let viewsDict = [
          "subject": subjectLabel,
          "subTitle": subTitleLabel,
          "content": contentLabel,
          "date": dateLabel
        ]

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[subject]-[date]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[content]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[subTitle]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[subject][subTitle][content]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[date][subTitle][content]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ListViewController: UIViewController {
    
    private let reuseIdentifier = "ListViewControllerCell"
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let listItems: [ListViewControllerCellData] = [
        .init(subject: "Adobe Sign", subTitle: "Drive business with digital signatures", content: "Drive business with digital signatures Get in touch to discover what Adobe Sign could do for youre buisness.", date: Date(), read: false),
        .init(subject: "Medium Daily Digest", subTitle: "New in iOS 14: App tests and more", content: "Stories for Ivanhulzen. Property Wrappers in Swift. 10 Tips on Developing iOS 14 widgets and apps.", date: Date(), read: true),
        .init(subject: "Google email verification", subTitle: "You received an account verification email", content: "If you received an account verification email in error, it's likely that another user accidentally entered your email while trying to recover their own email account.", date: Date(timeIntervalSinceNow: -1*24*60*60), read: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListViewControllerCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = 80
        
        view.setNeedsUpdateConstraints()
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

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListViewControllerCell
        
        if let data = listItems[indexPath.row] as ListViewControllerCellData? {
            cell.subjectLabel.text = data.subject
            cell.subTitleLabel.text = data.subTitle
            cell.contentLabel.text = data.content
            cell.dateLabel.text = data.date.formatRelativeString()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

