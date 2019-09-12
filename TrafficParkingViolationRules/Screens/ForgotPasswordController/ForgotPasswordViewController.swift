//
//  ForgotPasswordViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 24/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPasswordViewController: BaseClassViewController {
    
    @IBOutlet weak var emailBorder_outerView: UIView!
    @IBOutlet weak var emailBorder_innerView: UIView!
    @IBOutlet weak var email_txtField: UITextField!
    @IBOutlet weak var resetBtnBorder_outerView: UIView!
    @IBOutlet weak var resetBtnBorder_innerView: UIView!
    @IBOutlet weak var reset_Btn: UIButton!
    @IBOutlet weak var backOuter_borderView: UIView!
    @IBOutlet weak var backInner_borderView: UIView!
    @IBOutlet weak var back_Btn: UIButton!
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        email_txtField.setLeftPaddingPoints(10)
        viewInit()
    }
    
    func viewInit(){
        setTextFieldBorder(textFiled: email_txtField, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: emailBorder_outerView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: emailBorder_innerView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        
        self.setViewBorder(view: resetBtnBorder_outerView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: resetBtnBorder_innerView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setButtonBorder(button: reset_Btn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        
        self.setViewBorder(view: backOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: backInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setButtonBorder(button: back_Btn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
    }
    
    //MARK:- Api
    func forgotPassword() {
        let param: [String: String] = [
            "email" : email_txtField.text!,
        ]
        print(param)
        self.showCustomProgress()
        let api = Configurator.baseURL + ApiEndPoints.create
        Alamofire.request(api, method: .post, parameters: param, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                
                DispatchQueue.main.async {
                    self.stopProgress()
                }
                let resultDict = response.value as? NSDictionary
                if let mstStr = resultDict!["message"] as? String {
                    let alert = UIAlertController(title: "Alert", message:mstStr, preferredStyle: UIAlertController.Style.alert);
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                    self.email_txtField.text = ""
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    //MARK:- UIButton Actions
    @IBAction func actionResetBtn(_ sender: Any) {
        if email_txtField.text == "" {
            showAlert(title: "Alert!", message: "please enter email id!")
        }else if email_txtField.text != nil {
            if !isValidEmail(testStr: email_txtField.text!)  {
                showAlert(title: "Alert!", message: "Please enter valid email id!")
            }else{
                if Connectivity.isConnectedToInternet() {
                    forgotPassword()
                } else {
                    showAlert(title: "Alert!", message: "please check your internet connection")
                }
            }
        }
    }
    
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
