//
//  MenuViewController.swift
//  TrafficParkingViolationRules
//
//  Created by Mac-Mini- Nav on 19/08/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import AVFoundation
import SideMenu

class MenuViewController: BaseClassViewController {
    
    @IBOutlet weak var audioAcess_swtBtn: UISwitch!
    @IBOutlet weak var videoAcess_swtBtn: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUiInterface()
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors)  
    }
    
    func setUiInterface(){
          if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            print("CamaraAcessAuthorizes>>>")
            videoAcess_swtBtn.isOn = true
        } else {
            print("CamaraAcessUnAuthorizes>>>")
            videoAcess_swtBtn.isOn = false
        }
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            print("MicroPhoneAcessAuthorizes>>>")
            audioAcess_swtBtn.isOn = true
        } else {
            print("MicroPhoneAcessUnAuthorizes>>>")
            audioAcess_swtBtn.isOn = false
        }
    }
    
    @IBAction func actionAudioAcessBtn(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionVideoAcessBtn(_ sender: UISwitch){
        UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionForgotSecurityCode(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ForgotSecurityCodeViewController") as! ForgotSecurityCodeViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func actionViewProfileBtn(_ sender: Any) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "VideoCollectionViewController") as! VideoCollectionViewController
//        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func actionViewHistoryBtn(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "VideoCollectionViewController") as! VideoCollectionViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func actionLogoutBtn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "loginEmailId")
        UserDefaults.standard.removeObject(forKey: "loginPassword")
        UserDefaults.standard.removeObject(forKey: "passCodeSet")
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "Login_VC") as! Login_VC
        self.navigationController?.pushViewController(obj, animated: true)
    }
}



