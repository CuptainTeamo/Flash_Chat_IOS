//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleText = K.appName

        titleLabel.text = ""
        var charIndex = 0

        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(charIndex), repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1

        }
        
//        titleLabel.text = "⚡️FlashChat"
       
    }
    

    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender.currentTitle == "Register" {
            self.performSegue(withIdentifier: "goToRegister", sender: self)
        }
        
        if sender.currentTitle == "Log In" {
            performSegue(withIdentifier: "goToLogin", sender: self)
        }
    }
}
