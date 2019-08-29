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
import AVFoundation

class PasswordGetViewController: BaseClassViewController {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    
    var passCodeGetStr = String()
    
    var videoUrl = URL(string: "https://www.apple.com")
    var videoTitle = String()
    var videoDescription = String()
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var inputCodeStr = String()
    var thumbnail = UIImage()
    
    
    //MARK:- view DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("videoUrl>>>>>",videoUrl)
        generateThumbnail(path: videoUrl!)
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
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            thumbnail = UIImage(cgImage: cgImage)
            print("thumbnail>>>>>",thumbnail)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
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
                    //self.stopProgress()
                }
                if let resultDict = response.value as? NSDictionary{
                    if let sucessStr = resultDict["success"] as? Bool{
                        print(sucessStr)
                        if sucessStr{
                            print("video upload sucesss")
                            let authToken = "Bearer" + " " + UserDefaults.standard.string(forKey: "loginToken")!
                            self.videoUploadApi(password: self.passCodeGetStr, title: self.videoTitle, description: self.videoDescription, authtoken: authToken, accept: "application/json", thumbnail: self.thumbnail, video: self.videoUrl)
    
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
    
    
    func videoUploadApi(password:String,title:String,description:String,authtoken:String,accept:String,thumbnail:UIImage,video:URL?){
        // self.showCustomProgress()
        let api  = Configurator.baseURL + ApiEndPoints.uploadFile
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(password.data(using: String.Encoding.utf8)!, withName: "password")
                multipartFormData.append(title.data(using: String.Encoding.utf8)!, withName: "title")
                multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "description")
                 let url = video
                    if url != nil{
                    let dataVideo = NSData(contentsOf: url!)
                        multipartFormData.append(dataVideo! as Data , withName: "video" , fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).mov", mimeType: "mov")
                }
                let imgData = thumbnail.jpegData(compressionQuality: 0.5)
                    multipartFormData.append(imgData!, withName: "thumbnail", fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).jpeg", mimeType: "image/jpeg")
                print(multipartFormData)
        },
            to:api,headers:["Authorization": authtoken,"Accept":accept],
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response)
                        self.stopProgress()
                        var resultDict = response.value as? [String:Any]
                        if let sucessStr = resultDict!["success"] as? Bool{
                            print("sucess>>>>",sucessStr)
                            let obj = self.storyboard?.instantiateViewController(withIdentifier: "HowCanAssetViewController") as! HowCanAssetViewController
                            self.navigationController?.pushViewController(obj, animated: true)
                            self.showAlert(title: "Alert", message: "File Uploaded Successfully")
                        }
                        }
                        .uploadProgress { progress in // main queue by default
                            print("Upload Progress: \(progress.fractionCompleted)")
                    }
                    return
                case .failure(let encodingError):
                    debugPrint(encodingError)
                    self.stopProgress()
                }
        })
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


