//
//  PasswordGetViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 30/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import SmileLock
import Alamofire

class PasswordGetViewController: BaseClassViewController {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    var passCodeGetStr = String()
    var videoUrl = String()
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    
    //MARK:- view DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("passcodeStr>>>>>",passCodeGetStr)
        //create PasswordContainerView
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
    
    //MARK:- Api
    func passwordMatchApi(){
        let authToken = "Bearer" + " " + UserDefaults.standard.string(forKey: "loginToken")!
        let param: [String: String] = [
            "password" : passCodeGetStr
        ]
        
        let headers =  [
            "Authorization": authToken,
            "Accept": "application/json"
        ]
        print(headers)
        print(param)
        self.showCustomProgress()
        let api = Configurator.baseURL + ApiEndPoints.getUploadedFiles
        Alamofire.request(api, method: .post, parameters: param,encoding: JSONEncoding.default, headers: (headers as! HTTPHeaders))
            .responseJSON { response in
                print(response)
                DispatchQueue.main.async {
                    self.stopProgress()
                }
                if let resultDict = response.value as? NSDictionary{
                    if let sucessStr = resultDict["success"] as? Bool{
                        print(sucessStr)
                        if sucessStr{
                           print("video upload sucesss")
                        }else {
                            self.showAlert(title: "Alert!", message: "Provide valid cradencials")
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
        passCodeGetStr = input
        return input == input
    }
    func validationSuccess() {
        print("*️⃣ success!")
        passwordMatchApi()
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordMatchApi()
        passwordContainerView.wrongPassword()
    }
}


