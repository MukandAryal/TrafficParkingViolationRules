//
//  PasswordSetViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 24/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import SmileLock
import Alamofire

class PasswordSetViewController: BaseClassViewController {
    
     //MARK: Outlets
    @IBOutlet weak var passwordStackView: UIStackView!
    
    @IBOutlet weak var password_lbl: UILabel!
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var inputCodeStr = String()
    
     //MARK:- view DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "smilelock_delete"
        
        //customize password UI
        passwordContainerView.tintColor = UIColor.color(.textColor)
        passwordContainerView.highlightedColor = appUiInerFace.appColor
    }
    
     //MARK:- view WillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }
    
    //MARK:- Custom Aleart
    func showQuuestionFirstCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        let exitVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoSavePopUpViewController") as? VideoSavePopUpViewController
        
        
        
        // Create the dialog
        let popup = PopupDialog(viewController: exitVc!,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: true)
        
        exitVc?.titleLbl.text = "Do you want to save this content to your profile?"
        exitVc!.yes_Btn.addTargetClosure { _ in
            popup.dismiss()
            self.showQuestionSecondCustomDialog()
        }
        exitVc!.no_btn.addTargetClosure { _ in
            popup.dismiss()
        }
        
        present(popup, animated: animated, completion: nil)
    }
    
    func showQuestionSecondCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        let exitVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoSavePopUpViewController") as? VideoSavePopUpViewController
        
        // Create the dialog
        let popup = PopupDialog(viewController: exitVc!,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: true)
        
        exitVc?.titleLbl.text = "Do you want to send for legal services?"
        exitVc!.yes_Btn.addTargetClosure { _ in
            popup.dismiss()
            self.performSegue(withIdentifier: "setPassword", sender: self)
        }
        exitVc!.no_btn.addTargetClosure { _ in
            popup.dismiss()
        }
        present(popup, animated: animated, completion: nil)
    }
    
    //MARK:- Api
    func passwordSet(){
        let authToken = "Bearer" + " " + UserDefaults.standard.string(forKey: "loginToken")!
        let param: [String: String] = [
            "password" : inputCodeStr
        ]
        
        let headers =  [
            "Authorization": authToken,
            "Accept": "application/json"
        ]
        print(headers)
        print(param)
        self.showCustomProgress()
        let api = Configurator.baseURL + ApiEndPoints.setPassword
        Alamofire.request(api, method: .post, parameters: param,encoding: JSONEncoding.default, headers: headers)
            .responseData { responseData in
                print(responseData.data)
                DispatchQueue.main.async {
                    self.stopProgress()
                }
                if let resultDict = responseData.value as? NSDictionary{
                        if let sucessStr = resultDict["success"] as? Bool{
                            print(sucessStr)
                            if sucessStr{
                            DispatchQueue.main.async {
                                self.showQuuestionFirstCustomDialog()
                             }
                        }else {
                            self.showAlert(title: "Alert!", message: "sumthing wrong! please try again")
                            self.stopProgress()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.stopProgress()
                        }
                    }
                }
        }
    }
    
    
    //MARK:- Button Action
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- Password Set Method

extension PasswordSetViewController: PasswordInputCompleteProtocol {
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

private extension PasswordSetViewController {
    func validation(_ input: String) -> Bool {
        inputCodeStr = input
        return input == input
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        passwordSet()
        UserDefaults.standard.set(inputCodeStr, forKey: "passCodeSet")
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}

