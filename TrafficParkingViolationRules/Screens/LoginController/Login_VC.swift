//
//  Login_VC.swift
//  TrafficParkingViolationRules
//
//  Created by Kitlabs-M-0002 on 7/17/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import Alamofire

class Login_VC: BaseClassViewController {
    
    @IBOutlet var mainView: UIView!
    //MARK:- Outlets
    @IBOutlet weak var txtField_email: UITextField!
    @IBOutlet weak var txtField_password: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var emailOuter_borderView: UIView!
    @IBOutlet weak var emailInner_borderView: UIView!
    @IBOutlet weak var passwordOuter_borderView: UIView!
    @IBOutlet weak var passwordInner_BorderView: UIView!
    @IBOutlet weak var singUpOuter_borderView: UIView!
    @IBOutlet weak var singUpInneer_borderView: UIView!
    
    //MARK:- UIView life-cycle Methods
    override func viewDidLoad() {
        viewInit()
        self.navigationController?.isNavigationBarHidden = true
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }
    
    func viewInit(){
        setTextFieldBorder(textFiled: txtField_email, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        setTextFieldBorder(textFiled: txtField_password, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: emailOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: emailInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: passwordOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: passwordInner_BorderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: singUpOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: singUpInneer_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setButtonBorder(button: signInBtn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        txtField_email.setLeftPaddingPoints(10)
        txtField_password.setLeftPaddingPoints(10)
        signInBtn.backgroundColor = appUiInerFace.appBackGroundColor
                txtField_email.text = "vipan@gmail.com"
                txtField_password.text = "vipan@123"
    }
    
    //MARK:- Api
    func loginApi(){
        let param: [String: String] = [
            "email" : txtField_email.text!,
            "password" : txtField_password.text!,
        ]
        print(param)
        self.showCustomProgress()
        let api = Configurator.baseURL + ApiEndPoints.login
        Alamofire.request(api, method: .post, parameters: param, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                DispatchQueue.main.async {
                    self.stopProgress()
                }
                if let resultDict = response.value as? NSDictionary{
                    if let dataDict = resultDict["data"] as? NSDictionary{
                        if let tokenStr = dataDict["token"] {
                            print("tokenStr>>>>>>",tokenStr)
                            let token = dataDict["token"] as? String
                            UserDefaults.standard.set(token, forKey: "loginToken")
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(self.txtField_email.text, forKey: "loginEmailId")
                                UserDefaults.standard.set(self.txtField_password.text, forKey: "loginPassword")
                                let obj = self.storyboard?.instantiateViewController(withIdentifier: "HowCanAssetViewController") as! HowCanAssetViewController
                                self.navigationController?.pushViewController(obj, animated: false)
                            }
                        }else {
                            let msgStr = dataDict["msg"] as? String
                            self.showAlert(title: "Alert!", message: msgStr ?? "")
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
    
    //MARK:- UIButton Actions
    @IBAction func didPress_signIn(_ sender: UIButton) {
        if txtField_email.text == ""{
            showAlert(title: "Alert!", message: "Please enter username")
        }
        else if txtField_password.text == "" {
            showAlert(title: "Alert!", message: "Please enter password")
        }else{
            if Connectivity.isConnectedToInternet() {
                loginApi()
            } else {
                showAlert(title: "No Internet!", message: "Please check your internet connection")
            }
        }
    }
    
    @IBAction func didPress_register(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "NewUserEmailViewController") as! NewUserEmailViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    @IBAction func didPress_forgotPassword(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
}

