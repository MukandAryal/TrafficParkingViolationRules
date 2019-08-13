//
//  HowCanAssetViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 23/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit

class HowCanAssetViewController: BaseClassViewController {
    @IBOutlet weak var trafficViolationBtn: UIButton!
    @IBOutlet weak var parkingViolationBtn: UIButton!
    @IBOutlet weak var trafficOuter_BorderView: UIView!
    @IBOutlet weak var trafficInner_borderView: UIView!
    @IBOutlet weak var parkingOuter_borderView: UIView!
    @IBOutlet weak var parkingInner_borderView: UIView!
    
    //MARK: Property
    let isBlurUI = true
    
    var loginVCID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
         loginVCID = isBlurUI ? "PasswordSetViewController" : "PasswordLoginViewController"
    }
    
    override func viewWillAppear(_ animated: Bool) {
         viewInit()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func viewInit(){
        self.setButtonBorder(button: trafficViolationBtn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: trafficOuter_BorderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: trafficInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        
        self.setViewBorder(view: parkingViolationBtn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: parkingOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: parkingInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
    }
    
    func present(_ id: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id)
        // in iOS 10, the crossDissolve transtion is wired
        //        loginVC?.modalTransitionStyle = .crossDissolve
        loginVC?.modalPresentationStyle = .none
        present(loginVC!, animated: true, completion: nil)
    }
    
    @IBAction func actionTrafficVioationBtn(_ sender: Any) {
        let passwordSetStr = UserDefaults.standard.string(forKey: "passCodeSet")
        if passwordSetStr != nil{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "TrafficCamera_VC") as! TrafficCamera_VC
            self.navigationController?.pushViewController(obj, animated: true)
        }else{
         let obj = self.storyboard?.instantiateViewController(withIdentifier: "PasswordSetViewController") as! PasswordSetViewController
           obj.modalPresentationStyle = .none
            self.navigationController?.pushViewController(obj, animated: true)
            // present(loginVCID)
        }
    }
    
    @IBAction func actionParkingVioationBtn(_ sender: Any) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "VideoCollectionViewController") as! VideoCollectionViewController
//        self.navigationController?.pushViewController(obj, animated: true)
    }
}