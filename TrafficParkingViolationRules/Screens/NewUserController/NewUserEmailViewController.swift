//
//  NewUserEmailViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 23/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit

class NewUserEmailViewController: BaseClassViewController {
    @IBOutlet weak var firstName_txtField: UITextField!
    @IBOutlet weak var lastName_txtField: UITextField!
    @IBOutlet weak var userName_txtField: UITextField!
    @IBOutlet weak var next_Btn: UIButton!
    @IBOutlet weak var firstNameOuter_borderView: UIView!
    @IBOutlet weak var firstNameInner_borderView: UIView!
    @IBOutlet weak var lastNameOuter_borderView: UIView!
    @IBOutlet weak var lastNameInner_borderView: UIView!
    @IBOutlet weak var userNameOuter_borderView: UIView!
    @IBOutlet weak var userNameInner_borderView: UIView!
    @IBOutlet weak var singUpOuter_borderView: UIView!
    @IBOutlet weak var singUpInneer_borderView: UIView!
    var registrationData:newRegistration?
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    func viewInit(){
        setTextFieldBorder(textFiled: firstName_txtField, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        setTextFieldBorder(textFiled: lastName_txtField, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
          setTextFieldBorder(textFiled: userName_txtField, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: firstNameOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: firstNameInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: lastNameOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: lastNameInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: userNameOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: userNameInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: singUpOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: singUpInneer_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setButtonBorder(button: next_Btn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
         firstName_txtField.setLeftPaddingPoints(10)
         lastName_txtField.setLeftPaddingPoints(10)
         userName_txtField.setLeftPaddingPoints(10)
    }
    
      //MARK:- New Registraion
    func newUserRegistration() {
        if firstName_txtField.text == ""{
             self.showAlert(title: "Alert!", message: "Please enter firstname")
        }else if lastName_txtField.text == ""{
            self.showAlert(title: "Alert!", message: "Please enter lastname")
        }else if userName_txtField.text == ""{
             self.showAlert(title: "Alert!", message: "Please enter username")
        }else if userName_txtField.text != nil {
            if !isValidEmail(testStr: userName_txtField.text!)  {
                 self.showAlert(title: "Alert!", message: "Please enter valid email id")
            }else{
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "NewUserPasswordViewController") as! NewUserPasswordViewController
                registrationData = newRegistration.init(firstName: firstName_txtField.text, lastName: lastName_txtField.text, userName: userName_txtField.text)
                obj.registrationData = registrationData
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }
    }
    
    //MARK:- UIButton Actions
    @IBAction func actionNextBtn(_ sender: Any) {
       newUserRegistration()
    }
    
    @IBAction func actionSignInBtn(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "Login_VC") as! Login_VC
        self.navigationController?.pushViewController(obj, animated: true)
    }
}
