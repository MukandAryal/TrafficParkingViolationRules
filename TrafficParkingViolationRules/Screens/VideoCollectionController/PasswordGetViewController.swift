//
//  PasswordGetViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 30/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import SmileLock

class PasswordGetViewController: UIViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    
    var passCodeGetStr = String()
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
      passCodeGetStr = UserDefaults.standard.string(forKey: "passCodeSet") ?? ""
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "smilelock_delete"
        
        //customize password UI
        passwordContainerView.tintColor = UIColor.color(.textColor)
        passwordContainerView.highlightedColor = UIColor.color(.blue)
        
    }
}

extension PasswordGetViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasswordGetViewController {
    func validation(_ input: String) -> Bool {
        passCodeGetStr = input
        return input == input
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        // let obj = self.storyboard.
       // self.performSegue(withIdentifier: "setPassword", sender: self)
        //dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}


