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

class ListViewControllerCellIndicator: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isOpaque = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        tintColor.setFill()
        let indicator = UIBezierPath.init(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: self.frame.width / 2, startAngle: 0, endAngle: 360, clockwise: true)
        indicator.fill()
    }
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
    
    var indicator: ListViewControllerCellIndicator = {
        let view = ListViewControllerCellIndicator()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        
        contentView.addSubview(indicator)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)

        let viewsDict = [
            "indicator": indicator,
            "subject": subjectLabel,
            "subTitle": subTitleLabel,
            "content": contentLabel,
            "date": dateLabel
        ]

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[indicator(10)]-8-[subject]-[date]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[indicator(10)]-8-[content]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[indicator(10)]-8-[subTitle]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[subject][subTitle][content]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[date][subTitle][content]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[indicator][subTitle][content]-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ListViewController: UIViewController {
    var listItems: [Mail] = []
    
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
        
        if let data = listItems[indexPath.row] as Mail? {
            cell.subjectLabel.text = data.headline
            cell.subTitleLabel.text = data.subHeadline
            cell.contentLabel.text = data.content
            cell.dateLabel.text = data.date.formatRelativeString()
            cell.indicator.tintColor = data.read ? .clear : .systemBlue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

