//
//  UIInterFaceController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 23/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit

class UIInterFaceController: NSObject {

}

class appUiInerFace:NSObject{
    static let appTextColor = UIColor(red: 245/254, green: 172/254, blue: 76/254, alpha: 1.0).cgColor
    static let appBackGroundColor = UIColor(red: 241/254, green: 174/254, blue: 77/254, alpha: 1.0)
    static let textFieldOutBorderColor =  UIColor(red: 60/254, green: 57/254, blue: 50/254, alpha: 1.0)
    static let textFieldInBorderColor =  UIColor(red: 179/254, green: 174/254, blue: 169/254, alpha: 1.0)
     static let textFieldBorderColor =  UIColor(red: 255/254, green: 251/254, blue: 206/254, alpha: 1.0)
    static let appColor =  UIColor(red: 39/254, green: 62/254, blue: 126/254, alpha: 1.0)
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
