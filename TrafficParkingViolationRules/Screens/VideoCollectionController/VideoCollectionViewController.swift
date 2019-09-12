//
//  VideoCollectionViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 24/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation
import SDWebImage

struct recordVideoList {
    struct videoDetails {
        var created_at : String?
        var description : String?
        var id : Int?
        var status : Bool?
        var thumbnail : String?
        var title : String?
        var updated_at : String?
        var uploadUrl : String?
        var user_id : Int?
    }
    var videoInfo : [recordVideoList]
}

class VideoCollectionViewController: BaseClassViewController {
    @IBOutlet weak var videoCollectionView: UICollectionView!
    let isBlurUI = true
    var loginVCID: String!
    var videoArr = [recordVideoList.videoDetails]()
    
    //MARK:- App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors)
        let nib = UINib(nibName: "videoCollectionViewCell", bundle: nil)
        videoCollectionView?.register(nib, forCellWithReuseIdentifier: "videoCollectionViewCell")
        videoGetApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func present(_ id: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id)
        loginVC?.modalPresentationStyle = .overFullScreen
        present(loginVC!, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK:- Api
    func videoGetApi(){
        self.showCustomProgress()
        let authToken = "Bearer" + " " + UserDefaults.standard.string(forKey: "loginToken")!
        let param: [String: String] = [
            "password" : "123456"
        ]
        
        let headers =  [
            "Authorization": authToken,
            "Accept": "application/json"
        ]
        print(headers)
        print(param)
        let api = Configurator.baseURL + ApiEndPoints.getUploadedFiles
        Alamofire.request(api, method: .post, parameters: param,encoding: JSONEncoding.default, headers: (headers as! HTTPHeaders))
            .responseJSON { response in
                print(response)
                if let resultDict = response.value as? NSDictionary{
                    if let sucessStr = resultDict["success"] as? Bool{
                        print(sucessStr)
                        if sucessStr{
                            print("resultDict>>",resultDict)
                            if let messageArr = resultDict["message"] as? NSDictionary{
                                print("messageArr>>",messageArr)
                                if let dataDict = messageArr["data"] as? [[String:AnyObject]]{
                                    print("dataDict>>>>>",dataDict)
                                    for dataObj in dataDict {
                                        let video = recordVideoList.videoDetails(
                                            created_at: dataObj["created_at"] as? String,
                                            description: dataObj["description"] as? String,
                                            id: dataObj["id"] as? Int,
                                            status: dataObj["status"] as? Bool,
                                            thumbnail: dataObj["thumbnail"] as? String,
                                            title: dataObj["title"] as? String,
                                            updated_at: dataObj["updated_at"] as? String,
                                            uploadUrl: dataObj["uploadUrl"] as? String,
                                            user_id: dataObj["user_id"] as? Int)
                                        self.videoArr.append(video)
                                        print("videoArr<><><><>",self.videoArr)
                                        self.videoCollectionView.reloadData()
                                    }
                                    self.stopProgress()
                                }
                            }
                        }else{
                            self.showAlert(title: "Alert", message: "Sumthing wrong please try later")
                            self.stopProgress()
                        }
                    }
                }
        }
    }
    
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension VideoCollectionViewController : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.view.frame.width/2-0.5 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCollectionViewCell", for: indexPath as IndexPath) as! videoCollectionViewCell
        let imageStr = Configurator.imageBaseUrl + videoArr[indexPath.item].thumbnail!
        let videoUrl = Configurator.imageBaseUrl + videoArr[indexPath.item].uploadUrl!
        if videoUrl.suffix(4) == "jpeg"{
        cell.imageView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: "user_pic"))
        cell.video_icon.isHidden = true

        }else{
         cell.imageView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: "user_pic"))
         cell.video_icon.isHidden = false
        }
        return cell
        
    }
}

extension VideoCollectionViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoUrl = Configurator.imageBaseUrl + videoArr[indexPath.item].uploadUrl!
        if videoUrl.suffix(4) == "jpeg"{
            print("imagegtt>>>>>>>>>>>>>>")
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "PhotoZoomViewController") as! PhotoZoomViewController
            obj.imageGet = videoUrl
            self.navigationController?.pushViewController(obj, animated: true)        }else{
            let videoURL = URL(string: videoUrl)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}
