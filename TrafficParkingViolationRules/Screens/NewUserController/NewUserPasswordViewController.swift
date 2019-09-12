//
//  NewUserPasswordViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 23/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation


struct newRegistration {
    var firstName : String?
    var lastName : String?
    var userName : String?
}

class NewUserPasswordViewController: BaseClassViewController {
    
    @IBOutlet weak var password_txtField: UITextField!
    @IBOutlet weak var confrimPassword_txtField: UITextField!
    @IBOutlet weak var passwordOuter_borderView: UIView!
    @IBOutlet weak var passwordInner_borderView: UIView!
    @IBOutlet weak var confirmOuter_borderView: UIView!
    @IBOutlet weak var confrimInner_borderView: UIView!
    @IBOutlet weak var backOuter_borderView: UIView!
    @IBOutlet weak var backInner_borderView: UIView!
    @IBOutlet weak var back_Btn: UIButton!
    @IBOutlet weak var createAccountOuter_borderView: UIView!
    @IBOutlet weak var createAccountInner_borderView: UIView!
    @IBOutlet weak var createAccount_btn: UIButton!
    @IBOutlet weak var confrim_btn: UIView!
    var registrationData:newRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    func viewInit(){
        setTextFieldBorder(textFiled: password_txtField, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: passwordOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: passwordInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        
        setTextFieldBorder(textFiled: confrimPassword_txtField, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: confirmOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: confrimInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        
        self.setButtonBorder(button: createAccount_btn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: createAccountOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: createAccountInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        
        self.setButtonBorder(button: back_Btn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: backOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: backInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        password_txtField.setLeftPaddingPoints(10)
        confrimPassword_txtField.setLeftPaddingPoints(10)
        
    }
    
    //MARK:- Api
    func registraionApi(){
        let param: [String: String] = [
            "FirstName" : registrationData!.firstName!,
            "email" : registrationData!.userName!,
            "LastName" : registrationData!.lastName!,
            "password" : password_txtField.text!,
            "c_password" : confrimPassword_txtField.text!
        ]
        print(param)
        self.showCustomProgress()
        let api = Configurator.baseURL + ApiEndPoints.register
        Alamofire.request(api, method: .post, parameters: param, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                
                DispatchQueue.main.async {
                    self.stopProgress()
                }
                
                let resultDict = response.value as? NSDictionary
                if let dataDict = resultDict!["data"] as? NSDictionary {
                    if let tokenStr = dataDict["token"] {
                        print("tokenStr",tokenStr)
                        let token = dataDict["token"] as? String
                        UserDefaults.standard.set(token, forKey: "loginToken")
                        DispatchQueue.main.async {
                            self.proceedWithCameraAccess(identifier: "")
                            //                            let obj = self.storyboard?.instantiateViewController(withIdentifier: "HowCanAssetViewController") as! HowCanAssetViewController
                            //                            self.navigationController?.pushViewController(obj, animated: false)
                        }
                    }else {
                        var msgStr = String()
                        if let confirmPasswordStr = dataDict["email"] as? NSArray{
                            msgStr = (confirmPasswordStr[0] as? String)!
                            print("msgStr...",msgStr)
                            self.showAlert(title: "Alert!", message: msgStr)
                        }else{
                            self.showAlert(title: "Alert!", message: "Something wrong please try after some time")
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        self.stopProgress()
                    }
                }
        }
    }
    
    func proceedWithCameraAccess(identifier: String){
        // handler in .requestAccess is needed to process user's answer to our request
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success { // if request is granted (success is true)
                DispatchQueue.main.async {
                    // self.performSegue(withIdentifier: identifier, sender: nil)
                    self.proceedWithMicroPhoneAccess(identifier: "")
                }
                
            } else { // if request is denied (success is false)
                // Create Alert
                let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)
                
                // Add "OK" Button to alert, pressing it will bring you to the settings app
    
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    
                }))
                // Show the alert with animation
                self.present(alert, animated: true)
            }
        }
    }
    
    func proceedWithMicroPhoneAccess(identifier: String){
        // handler in .requestAccess is needed to process user's answer to our request
        AVCaptureDevice.requestAccess(for: .audio) { success in
            if success { // if request is granted (success is true)
                DispatchQueue.main.async {
                    // self.performSegue(withIdentifier: identifier, sender: nil)
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "PasswordSetViewController") as! PasswordSetViewController
                    self.navigationController?.pushViewController(obj, animated: false)
                }
            } else { // if request is denied (success is false)
                // Create Alert
                let alert = UIAlertController(title: "Audio", message: "Microphone access is absolutely necessary to use this app", preferredStyle: .alert)
                
                // Add "OK" Button to alert, pressing it will bring you to the settings app
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    
                }))
                // Show the alert with animation
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionCreateAccountBtn(_ sender: Any) {
        if password_txtField.text == "" {
            self.showAlert(title: "Alert!", message: "Please enter password")
        }else if confrimPassword_txtField.text == ""{
            self.showAlert(title: "Alert!", message: "Please enter confirm password")
        }else if password_txtField.text != confrimPassword_txtField.text {
            self.showAlert(title: "Alert!", message: "he password and confirm password must match")
        }
        else{
            if Connectivity.isConnectedToInternet() {
                registraionApi()
            } else {
                self.showAlert(title: "No Internet!", message: "Please check your internet connection")
            }
        }
    }
}

