//
//  VideoCollectionViewController.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 24/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit

class VideoCollectionViewController: BaseClassViewController {
    @IBOutlet weak var videoCollectionView: UICollectionView!
    let isBlurUI = true
    
    var loginVCID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "videoCollectionViewCell", bundle: nil)
        videoCollectionView?.register(nib, forCellWithReuseIdentifier: "videoCollectionViewCell")
        loginVCID = isBlurUI ? "BlurPasswordLoginViewController" : "PasswordLoginViewController"
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = appUiInerFace.appColor
    }
    
    func present(_ id: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id)
        loginVC?.modalPresentationStyle = .overFullScreen
        present(loginVC!, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCollectionViewCell", for: indexPath as IndexPath) as! videoCollectionViewCell

    return cell
        
    }
}

extension VideoCollectionViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let refreshAlert = UIAlertController(title: "Alert", message: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu.", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            self.present(self.loginVCID)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
}
