//
//  ApiEndPoints.swift
//  TrafficParkingViolationRules
//
//  Created by osvinuser on 29/07/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import Alamofire

let SuccessCode: NSNumber = 200
let FailureCode: NSNumber = 99

class Configurator: NSObject {
    static let baseURL = "http://3.13.127.23/index.php/api/"
    static let videoUploadUrl = "http://3.13.127.23/api/"
}

class ApiEndPoints: NSObject {
   static let login = "login"
   static let register = "register"
   static let create = "create"
   static let uploadFile = "uploadFile"
   static let setPassword = "addPassword"
   static let getUploadedFiles = "getUploadedFiles"
}

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
