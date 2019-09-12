//
//  PhotoZoomViewController.swift
//  TrafficParkingViolationRules
//
//  Created by Apple SSD2 on 11/09/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit

class PhotoZoomViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgPhoto: UIImageView!
    var imageGet = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("imageGet>>>>>.",imageGet)
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        //let imageStr = Configurator.imageBaseUrl + imageGet
         //print("imageStr>>>>>>>>>>>")
        imgPhoto.sd_setImage(with: URL(string: imageGet), placeholderImage: UIImage(named: "user_pic"))
        print("imageStr>>>>>>>>>>>")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imgPhoto
    }
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
