//
//  NewViewController.swift
//  mailbox
//
//  Created by Ingmar van Hulzen on 02/09/2020.
//  Copyright © 2020 Ingmar van Hulzen. All rights reserved.
//

import UIKit

class InputField: UITextField {
    
    var label: UILabel = {
        var label = UILabel()
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let border = CALayer()
    let borderWidth = 1 / UIScreen.main.scale

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftView = label
        leftViewMode = .always
        translatesAutoresizingMaskIntoConstraints = false
        
        border.borderColor = UIColor.separator.cgColor
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: frame.size.height)
        border.borderWidth = borderWidth
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width:  frame.size.width, height: frame.size.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NewViewController: UIViewController {
    
    var toField: InputField = {
        var input = InputField()
        input.label.text = "To: "
        return input
    }()
    
    var fromField: InputField = {
        var input = InputField()
        input.label.text = "From: "
        return input
    }()
    
    var subjectField: InputField = {
        var input = InputField()
        input.label.text = "Subject: "
        return input
    }()
    
    var contentField: UITextView = {
        var input = UITextView()
        input.translatesAutoresizingMaskIntoConstraints = false
        input.textContainerInset = .zero
        input.textContainer.lineFragmentPadding = 0
        input.isScrollEnabled = true
        input.scrollRangeToVisible(NSMakeRange(0, 0))
        return input
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissScene))
        
        view.setNeedsUpdateConstraints()
        
        // Match font size to label
        contentField.font = toField.font
        
        view.addSubview(toField)
        view.addSubview(fromField)
        view.addSubview(subjectField)
        view.addSubview(contentField)
        
        // KeyBoard notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func updateViewConstraints() {
        let viewsDict = [
            "to": toField,
            "from": fromField,
            "subject": subjectField,
            "content": contentField,
        ]

        let constraints = [
            "H:|-[to]-|",
            "H:|-[from]-|",
            "H:|-[subject]-|",
            "H:|-[content]-|",
            "V:|-[to(44)]-[from(44)]-[subject(44)]-[content]-|",
        ]

        constraints.forEach({
            view.addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: viewsDict)
            )
        })

        super.updateViewConstraints()
    }
}

extension NewViewController {
    
    @objc private func dismissScene() {
        dismiss(animated: true, completion: {})
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            contentField.contentInset = .zero
        } else {
            contentField.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardViewEndFrame.height + NSLayoutConstraint.standardConstantBetweenSiblings) - view.safeAreaInsets.bottom, right: 0)
        }

        contentField.scrollIndicatorInsets = contentField.contentInset

        let selectedRange = contentField.selectedRange
        contentField.scrollRangeToVisible(selectedRange)
    }
}

extension NSLayoutConstraint {
    
    static var standardConstantBetweenSiblings: CGFloat {
        get {
            let view = UIView()
            let constraint = NSLayoutConstraint.constraints(withVisualFormat: "[view]-[view]", options: [], metrics: nil, views: ["view": view])[0]
            return constraint.constant // 8.0
        }
    }
    
}
