//
//  HowCanAssetViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 23/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import SideMenu
import TLPhotoPicker
import Photos

class HowCanAssetViewController: BaseClassViewController,TLPhotosPickerViewControllerDelegate {
    @IBOutlet weak var trafficViolationBtn: UIButton!
    @IBOutlet weak var parkingViolationBtn: UIButton!
    @IBOutlet weak var trafficOuter_BorderView: UIView!
    @IBOutlet weak var trafficInner_borderView: UIView!
    @IBOutlet weak var parkingOuter_borderView: UIView!
    @IBOutlet weak var parkingInner_borderView: UIView!
    
    //MARK: Property
    let isBlurUI = true
    var loginVCID: String!
    var imagePicker = UIImagePickerController()
    var videoURL: NSURL?
    var parkingVideoUrl:URL? = nil
    var parkingImgView = UIImage()
    var selectedAssets = [TLPHAsset]()
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!

    
    //MARK: view DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        viewInit()
        loginVCID = isBlurUI ? "PasswordSetViewController" : "PasswordLoginViewController"
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }
    
    //MARK: setupSideMenu
    private func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    //MARK: view WillAppear
    override func viewWillAppear(_ animated: Bool) {
        viewInit()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: setUp Interface
    func viewInit(){
        //  setNavigationBackgroundColor()
        self.setButtonBorder(button: trafficViolationBtn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: trafficOuter_BorderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: trafficInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
        self.setViewBorder(view: parkingViolationBtn, borderWidth: 2, borderColor: appUiInerFace.textFieldBorderColor)
        self.setViewBorder(view: parkingOuter_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldOutBorderColor)
        self.setViewBorder(view: parkingInner_borderView, borderWidth: 2, borderColor: appUiInerFace.textFieldInBorderColor)
    }
    
    //MARK: present
    func present(_ id: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id)
        loginVC?.modalPresentationStyle = .none
        present(loginVC!, animated: true, completion: nil)
    }
    
    //MARK: Button Action
    @IBAction func actionTrafficVioationBtn(_ sender: Any) {
        UserDefaults.standard.set("trafficViolation", forKey: "trafficViolation")
        let passwordSetStr = UserDefaults.standard.string(forKey: "passCodeSet")
        if passwordSetStr != nil{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "TrafficCamera_VC") as! TrafficCamera_VC
            self.navigationController?.pushViewController(obj, animated: true)
        }else{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "PasswordSetViewController") as! PasswordSetViewController
            // obj.modalPresentationStyle = .none
            self.navigationController?.pushViewController(obj, animated: true)
            // present(loginVCID)
        }
    }
    
    @IBAction func actionParkingVioationBtn(_ sender: Any) {
        UserDefaults.standard.set("parkingViolation", forKey: "trafficViolation")
        let viewController = CustomPhotoPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        viewController.logDelegate = self
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func movePassCodeView(){
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "PasswordGetViewController") as! PasswordGetViewController
        print("parkingVideoUrl>>>>>>",parkingVideoUrl)
        print("parkingVideoUrl>>>>>>",parkingImgView)
        if parkingVideoUrl != nil{
             obj.videoUrl = parkingVideoUrl
        }
        obj.parkingImg = parkingImgView
        self.navigationController?.pushViewController(obj, animated: true)
    }

    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        getFirstSelectedImage()
        //iCloud or video
        //        getAsyncCopyTemporaryFile()
    }
    
    func exportVideo() {
        if let asset = self.selectedAssets.first, asset.type == .video {
            asset.exportVideoFile(progressBlock: { (progress) in
                print(progress)
            }) { (url, mimeType) in
                print("completion\(url)")
                self.parkingVideoUrl = url
                print("parkingVideoUrl>>>>>>>",self.parkingVideoUrl)
                print(mimeType)
                self.movePassCodeView()
            }
        }
    }
    
    func getAsyncCopyTemporaryFile() {
        if let asset = self.selectedAssets.first {
            asset.tempCopyMediaFile(convertLivePhotosToJPG: false, progressBlock: { (progress) in
                print(progress)
            }, completionBlock: { (url, mimeType) in
                print("completion\(url)")
                print(mimeType)
            })
        }
    }
    
    func getFirstSelectedImage() {
        if let asset = self.selectedAssets.first {
            if asset.type == .video {
                asset.videoSize(completion: { [weak self] (size) in
                    //self?.label.text = "video file size\(size)"
                    print("video file size")
                    self?.exportVideo()
                })
                return
            }
            if let image = asset.fullResolutionImage {
                print("imageSeleted>>>>>>>",image)
                UserDefaults.standard.set("parkingImage", forKey: "trafficViolation")
                parkingImgView = image
                self.movePassCodeView()
               // self.label.text = "local storage image"
                //self.imageView.image = image
            }else {
                print("Can't get image at local storage, try download image")
                asset.cloudImageDownload(progressBlock: { [weak self] (progress) in
                    DispatchQueue.main.async {
                       // self?.label.text = "download \(100*progress)%"
                        print("download>>>>>>",progress)
                    }
                    }, completionBlock: { [weak self] (image) in
                        if let image = image {
                            //use image
                            DispatchQueue.main.async {
                             //   self?.label.text = "complete download"
                               // self?.imageView.image = image
                                print("download>>>>>>",image)
                            }
                        }
                })
            }
        }
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }
    
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker dismiss completion
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) {
            let alert = UIAlertController(title: "", message: "Denied albums permissions granted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "Denied camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showUnsatisifiedSizeAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Oups!", message: "The required size is: 300 x 300", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

extension HowCanAssetViewController: TLPhotosPickerLogDelegate {
    //For Log User Interaction
    func selectedCameraCell(picker: TLPhotosPickerViewController) {
        print("selectedCameraCell")
    }
    
    func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("selectedPhoto")
    }
    
    func deselectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("deselectedPhoto")
    }
    
    func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {
        print("selectedAlbum")
    }
}

