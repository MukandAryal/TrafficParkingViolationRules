//
//  PasswordGetViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 30/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import SmileLock

class PasswordGetViewController: BaseClassViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    
    var passCodeGetStr = String()
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passCodeGetStr = UserDefaults.standard.string(forKey: "passCodeSet") ?? ""
        print("passcodeStr>>>>>",passCodeGetStr)
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "smilelock_delete"
        //customize password UI
        passwordContainerView.tintColor = UIColor.color(.textColor)
        passwordContainerView.highlightedColor = UIColor.color(.blue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
          self.navigationController?.isNavigationBarHidden = false
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }
    @IBAction func actionBackBtn(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HowCanAssetViewController") as! HowCanAssetViewController
        self.navigationController?.pushViewController(obj, animated: true)
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
        // passCodeGetStr = input
         return input == passCodeGetStr
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


