# iOS 13 Mailbox clone

In this project I will try to recreate the iOS 13 mailbox app. I will only build the plain views and won't connect it to a real email client. This is project is just to learn the basics of Swift and UIKit. And by recreating an existing app I will cover alot of basics. 

## Screenshots

| ![Mailboxes](https://raw.githubusercontent.com/ivhdevelopment/mailbox/master/screenshots/mailboxes.png) | ![New mail](https://raw.githubusercontent.com/ivhdevelopment/mailbox/master/screenshots/new-mail.png) | ![Mailbox](https://raw.githubusercontent.com/ivhdevelopment/mailbox/master/screenshots/mailbox.png) |
|:---:|:---:|:---:|
| Mailboxes | New mail | Mailbox |

## What have I done

I did setup a CoreData store with custom Mail and Mailbox models, these models are extended with methods for useful actions (like image, natural date representations and FetchRequest filters). These methods are used at the Mailboxes and Mailbox screens in the mailbox screen I've created a custom TableViewCell so that all the information is visible (just like the real mail app). The mailbox screen also has a drag to Read or Unread action. The create screen is made with Autolayout and an custom UITextField.