//
//  ForgotSecurityCodeViewController.swift
//  TrafficParkingViolationRules
//
//  Created by Apple SSD2 on 27/08/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import SmileLock
import Alamofire


class ForgotSecurityCodeViewController: BaseClassViewController {

     @IBOutlet weak var passwordStackView: UIStackView!
     var inputCodeStr = String()

    @IBOutlet weak var saveBtn: UIBarButtonItem!
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    
    //MARK:- view DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "smilelock_delete"
        //customize password UI
        passwordContainerView.tintColor = UIColor.color(.textColor)
        passwordContainerView.highlightedColor = appUiInerFace.appColor
        saveBtn.isEnabled = false
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
            .responseJSON { response in
                print(response)
                DispatchQueue.main.async {
                    self.stopProgress()
                }
                if let resultDict = response.value as? NSDictionary{
                    if let sucessStr = resultDict["success"] as? Bool{
                        print(sucessStr)
                        if sucessStr{
                            let obj = self.storyboard?.instantiateViewController(withIdentifier: "HowCanAssetViewController") as! HowCanAssetViewController
                           self.navigationController?.pushViewController(obj, animated: true)
                            self.showAlert(title: "Alert!", message: "Security Code Forgot Sucessfully")
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
    
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSubmitButton(_ sender: Any) {
        passwordSet()
    }
}



//MARK:- Password Set Method

extension ForgotSecurityCodeViewController: PasswordInputCompleteProtocol {
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

private extension ForgotSecurityCodeViewController {
    func validation(_ input: String) -> Bool {
        inputCodeStr = input
        return input == input
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
       // passwordSet()
        UserDefaults.standard.set(inputCodeStr, forKey: "passCodeSet")
        saveBtn.isEnabled = true
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}


