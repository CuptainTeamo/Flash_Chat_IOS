//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        // register table view
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)

        readMessages()
    }
    
    func readMessages() {
        
        // use get document
//        db.collection(K.FStore.collectionName).getDocuments { querySnapshot, error in
//            if let e = error {
//                print("There was a issue retrieving data from Firestore. \(e)")
//            } else {
//                // 1. store the safe data
//                if let snapshotDocuments = querySnapshot?.documents {
//                    // 2. loop the documents array
//                    for doc in snapshotDocuments {
//                        // 3. save the data into a data variable
//                        let data = doc.data()
//                        // 4. cast the data to String "as?" and save safe data
//                        if let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String {
//                            // 5. create the new message
//                            let newMessage = Message(sender: sender, body: body)
//                            // 6. append the newMessage to messages
//                            self.messages.append(newMessage)
//
//                            // 7. reload date to table view
//                            // make sure fetch the main thread
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                            }
//
//                        }
//                    }
//                }
//            }
//        }
        
        // order by will sort the messages
        // use add database listener methods
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
            // if there is error
            if let e = error {
                print("there wa error retrieving data \(e)")
            } else {
                // clear the old messages
                self.messages = []
                // save safe data
                if let snapshotDocuments = querySnapshot?.documents {
                    // loop through documents
                    for doc in snapshotDocuments {
                        // save the data from doc
                        let data = doc.data()
                        // save the safe data
                        // cast data to string
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            // form the message
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            // back to main thread, update table view
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text,let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let e = error {
                    print("There was a issue saving data to firestore \(e)")
                } else {
                    print("successfully saved data")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                    
                }
            }
        }
    }
    
    @IBAction func logOurPressed(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        // this is the message from current user
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.contentMode = .topRight
            cell.label.textAlignment = .right
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
        } else {
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.contentMode = .topLeft
            cell.label.textAlignment = .left
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
        }
            
        
        return cell
    }
}
