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
    var parkingVideoUrl = URL(string: "https://www.apple.com")
    var videoUrl = URL(string: "https://www.apple.com")
    var parkingImg = UIImage()
    var videoTitle = String()
    var videoDescription = String()
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var inputCodeStr = String()
    var thumbnail = UIImage()
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
    var compressedFileData : Data? =  nil
    
    
    //MARK:- view DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("videoUrl>>>>>",videoUrl ?? "")
        print("uiimage>>>>>",parkingImg)
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
    
    //MARK:- GetVideo Through Thumbnail Image
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
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4 //AVFileTypeQuickTimeMovie (m4v)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    //MARK:- passwordMatchApi
    func passwordMatchApi(){
        let authToken = "Bearer" + " " + UserDefaults.standard.string(forKey: "loginToken")!
        let param: [String: String] = [
            "password" : passCodeGetStr
        ]
        let head =  [
            "Authorization": authToken,
            "Accept": "application/json"
        ]
        print(head)
        print(param)
        // self.showCustomProgress()
        let api = Configurator.baseURL + ApiEndPoints.getUploadedFiles
        Alamofire.request(api, method: .post, parameters: param,encoding: JSONEncoding.default, headers: head)
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
                            print("compressedFileData>>>>>>>>>",self.compressedFileData)
                            let authToken = "Bearer" + " " + UserDefaults.standard.string(forKey: "loginToken")!
                            let parkingViolation = UserDefaults.standard.string(forKey: "trafficViolation")
                            if parkingViolation == "trafficViolation"{
                                self.videoUploadApi(password: self.passCodeGetStr, title: self.videoTitle, description: "checking video", authtoken: authToken, accept: "application/json", thumbnail: self.thumbnail, type: "Trafic", video: self.compressedFileData! as NSData)
                            }else if parkingViolation == "parkingViolation" {
                                self.videoUploadApi(password: self.passCodeGetStr, title: self.videoTitle, description: self.videoDescription, authtoken: authToken, accept: "application/json", thumbnail: self.thumbnail, type: "Parking", video: self.compressedFileData! as NSData)
                            }else{
                                self.imageUploadApi(password: self.passCodeGetStr, title: self.videoTitle, description: self.videoDescription, authtoken: authToken, accept: "application/json", type: "Parking", thumbnail:self.parkingImg, image: self.parkingImg)
                            }
                            
                        }else {
                            self.showAlert(title: "Alert!", message: "Provide valid cradencials")
                            self.passwordContainerView.clearInput()
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
    
    func apiCall(){
        print("videoUrl>>>>>>>>>>>>>>>>>",videoUrl)
        compressVideo(inputURL: videoUrl!, outputURL: compressedURL, handler: { (_ exportSession: AVAssetExportSession?) -> Void in
            self.showCustomProgress()
            switch exportSession!.status {
            case .completed:
                
                print("Video compressed successfully")
                do {
                    self.compressedFileData = try Data(contentsOf: exportSession!.outputURL!)
                    // Call upload function here using compressedFileData
                    self.passwordMatchApi()
                } catch _ {
                    print ("Error converting compressed file to Data")
                }
                
            default:
                print("Could not compress video")
                 self.passwordMatchApi()
            }
        } )
    }
    
    //MARK:- Traffic VideoLoadApi
    func videoUploadApi(password:String,title:String,description:String,authtoken:String,accept:String,thumbnail:UIImage,type:String,video:NSData){
        // self.showCustomProgress()
        let api  = Configurator.baseURL + ApiEndPoints.uploadFile
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(password.data(using: String.Encoding.utf8)!, withName: "password")
                multipartFormData.append(title.data(using: String.Encoding.utf8)!, withName: "title")
                multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "description")
                multipartFormData.append(type.data(using: String.Encoding.utf8)!, withName: "type")
                // let url = video
                //  if let url = video {
                // print(url)
                //  let dataVideo = NSData(contentsOf: url as URL)!
                // print(dataVideo)
                multipartFormData.append(self.compressedFileData! , withName: "video" , fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).mov", mimeType: "video/mp4")
                
                print(multipartFormData)
                // }
                if  let imgData = thumbnail.jpegData(compressionQuality: 0.5){
                    multipartFormData.append(imgData, withName: "thumbnail", fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).jpeg", mimeType: "image/jpeg")
                    print(multipartFormData)
                }
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
    
    //MARK:- parking upLoadApi
    func imageUploadApi(password:String,title:String,description:String,authtoken:String,accept:String,type:String,thumbnail:UIImage,image:UIImage){
        // self.showCustomProgress()
        let api  = Configurator.baseURL + ApiEndPoints.uploadFile
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(password.data(using: String.Encoding.utf8)!, withName: "password")
                multipartFormData.append(title.data(using: String.Encoding.utf8)!, withName: "title")
                multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "description")
                if let imgData = image.jpegData(compressionQuality: 0.5){
                    multipartFormData.append(imgData, withName: "video", fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).jpeg", mimeType: "image/jpeg")
                    print(multipartFormData)
                }
                if let imgData = thumbnail.jpegData(compressionQuality: 0.5){
                    multipartFormData.append(imgData, withName: "thumbnail", fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).jpeg", mimeType: "image/jpeg")
                    print(multipartFormData)
                }
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

//MARK:- Password Input CompleteProtocol
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

//MARK:- Password validation
private extension PasswordGetViewController {
    func validation(_ input: String) -> Bool {
        passCodeGetStr = input
        return input == input
    }
    func validationSuccess() {
        print("*️⃣ success!")
        //passwordMatchApi()
        apiCall()
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}


