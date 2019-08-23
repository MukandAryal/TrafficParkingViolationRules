//
//  TrafficCamera_VC.swift
//  TrafficParkingViolationRules
//
//  Created by Kitlabs-M-0002 on 7/17/19.
//  Copyright © 2019 Kitlabs-M-0002. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Alamofire



class TrafficCamera_VC: BaseClassViewController , AVCaptureFileOutputRecordingDelegate  {
    @IBOutlet weak var myView: UIView!
    @IBOutlet var durationTxt: UILabel!
    @IBOutlet var playerView: UIView!
    @IBOutlet weak var info_View: UIView!
    @IBOutlet weak var playControlView: UIView!
    @IBOutlet weak var description_userTxtView: UITextView!
    @IBOutlet weak var startRecordingBtn: UIButton!
    @IBOutlet weak var description_Lbl: UILabel!
    @IBOutlet weak var descriptionHeading_Lbl: UILabel!
    @IBOutlet weak var textView_heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var recordingStartStop_lbl: UILabel!
    @IBOutlet weak var recording_btn: UIButton!
    @IBOutlet weak var camara_Btn: UIButton!
    @IBOutlet weak var duration_countHeight: NSLayoutConstraint!
    
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    
    var outputURL: URL!
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var url = NSURL()
    var seconds: Int!
    var durationTimer: Timer?
    var videoURL: URL!
    var timeMin = 0
    var timeSec = 0
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUiInterface()
        let colors: [UIColor] = [UIColor(red: 16/254, green: 57/254, blue: 136/254, alpha: 1.0), UIColor(red: 60/254, green: 81/254, blue: 136/254, alpha: 1.0)]
        navigationController?.navigationBar.setGradientBackground(colors: colors) 
    }
    
    func setUiInterface(){
        setNavigationBackgroundColor()
        description_userTxtView.text = "1. Uplon request, show them your driver's license,registration, and proof of insurance. In certain cases, your car can be searched without a warrant as long as the police have probablecause. To protect yourself later,you should make it clear that you do not consent to a search.it is not lawful for police to arrest you simply for refusing to consent to a search."
        textView_heightConstraints.constant = 158
        duration_countHeight.constant = 0
        durationTxt.isHidden = true
        if setupSession() {
            setupPreview()
            startSession()
        }
        recording_btn.addTarget(self, action: #selector(recordingStart), for: .touchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: Selector(("someAction:")))
        // or for swift 2 +
        self.myView.addGestureRecognizer(gesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func videoUploadApi(password:String,title:String,description:String,video:URL?){
        self.showCustomProgress()
        let api  = Configurator.baseURL + ApiEndPoints.uploadFile
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(password.data(using: String.Encoding.utf8)!, withName: "password")
                multipartFormData.append(title.data(using: String.Encoding.utf8)!, withName: "type")
                multipartFormData.append(description.data(using: String.Encoding.utf8)!, withName: "description")
                if let url = video {
                    print(url)
                    let dataVideo = NSData(contentsOf: url as URL)!
                    print(dataVideo)
                    multipartFormData.append(dataVideo as Data , withName: "video" , fileName: "\(String(NSDate().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).acc", mimeType: "audio/aac")
                    
                }
                print(multipartFormData)
        },
            to:api,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //   print(response)
                        self.stopProgress()
                        var resultDict = response.value as? [String:Any]
                        if let sucessStr = resultDict!["success"] as? Bool{
                            print("sucess>>>>",sucessStr)
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
    
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        // do other task
        print("touchBegain>>>>>>>.")
        durationTxt.isHidden = false
        recording_btn.isHidden = false
        startTimerCount()
    }
    
    func startTimerCount(){
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
            self.durationTxt.isHidden = true
            self.recording_btn.isHidden = true
        }
    }
    
    func showCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        let exitVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoSavePopUpViewController") as? VideoSavePopUpViewController
        
        
        
        // Create the dialog
        let popup = PopupDialog(viewController: exitVc!,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: true)
        
        exitVc?.titleLbl.text = "Would you like to save\n this trafic video for\n legal representation?"
        exitVc!.yes_Btn.addTargetClosure { _ in
            popup.dismiss()
            self.stopTimer()
            self.resetTimerToZero()
            self.stopRecording()
            self.movePassCodeView()
        }
        exitVc!.no_btn.addTargetClosure { _ in
            popup.dismiss()
            //            self.stopTimer()
            //            resetTimerToZero()
        }
        
        present(popup, animated: animated, completion: nil)
    }
    
    func startTimer(){
        // If you don't use the 2 lines above then the timer will continue from whatever time it was stopped at
        let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
        durationTxt.text = timeNow
        stopTimer() // stop it at it's current time before starting it again
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func timerTick(){
        timeSec += 1
        
        if timeSec == 60{
            timeSec = 0
            timeMin += 1
        }
        
        let timeNow = String(format: "%02d:%02d", timeMin, timeSec)
        durationTxt.text = timeNow
        if timeNow == "00:05"{
            durationTxt.isHidden = true
            recording_btn.isHidden = true
        }
    }
    
    // resets both vars back to 0 and when the timer starts again it will start at 0
    @objc fileprivate func resetTimerToZero(){
        timeSec = 0
        timeMin = 0
        stopTimer()
    }
    
    // if you need to reset the timer to 0 and yourLabel.txt back to 00:00
    func resetTimerAndLabel(){
        
        resetTimerToZero()
        durationTxt.text = String(format: "%02d:%02d", timeMin, timeSec)
    }
    
    // stops the timer at it's current time
    func stopTimer(){
        timer?.invalidate()
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = myView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        myView.layer.addSublayer(previewLayer)
    }
    
    
    func movePassCodeView(){
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "PasswordGetViewController") as! PasswordGetViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        //captureSession.startse
        // Setup Camera
        let camera =  AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)//addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        movieOutput.maxRecordedDuration = CMTimeMake(value: 9, timescale: 1)
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func startCapture() {
        
        startRecording()
        
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                    recording_btn.addTarget(self, action: #selector(recordingStop), for: .touchUpInside)
                    
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self as! AVCaptureFileOutputRecordingDelegate)
            startTimer()
        }
        else {
            stopTimer()
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            
            print("Error recording movie: \(error!.localizedDescription)")
            
        } else {
            
            videoURL = outputURL! as URL
            print("videoRecorder>>>>>>",videoURL)
            //  performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            _ = outputURL as URL
            
        }
        outputURL = nil
        let pathString = outputFileURL.relativePath
        url = NSURL.fileURL(withPath: pathString) as NSURL
        print(url)
    }
    
    @objc func recordingStart(sender:UIButton!) {
        print("start Recording>>>>")
        recordingStartStop_lbl.text = "Prep"
        durationTxt.isHidden = false
        description_userTxtView.isHidden = true
        descriptionHeading_Lbl.isHidden = true
        description_userTxtView.text = ""
        textView_heightConstraints.constant = 0
        duration_countHeight.constant = 20
        startRecordingBtn.isHidden = true
        startRecording()
    }
    
    @objc func recordingStop(sender:UIButton!) {
        self.showCustomDialog()
        stopRecording()
        recordingStartStop_lbl.text = "Video Stopped"
        print("stop Recording>>>>")
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        
    }
    
    @IBAction func stopAction(_ sender: Any) {
        //stopRecording()
        if movieOutput.isRecording == true
        {
            self.durationTimer?.invalidate()
            self.durationTimer = nil
            self.seconds = 0
            self.durationTxt.text = secondsToFormatTimeFull(second: 0)
            stopRecording()
        }
    }
    @IBAction func actionBackBtn(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HowCanAssetViewController") as! HowCanAssetViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @objc func refreshDurationLabel() {
        
        self.durationTxt.text = secondsToFormatTimeFull(second: Double(self.seconds))
        seconds = seconds - 1
    }
    
    func secondsToFormatTimeFull(second: Double)->String
    {
        return "00:\(second)"
    }
    
    func changeCameraButtonClick(sender: AnyObject) {
        
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        self.seconds = 0
        self.durationTxt.text = secondsToFormatTimeFull(second: 0)
        stopRecording()
        
        let currentCameraInput: AVCaptureInput = captureSession.inputs[0] as! AVCaptureInput
        captureSession.removeInput(currentCameraInput)
        var newCamera: AVCaptureDevice
        if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
            newCamera = self.cameraWithPosition(position: .front)!
        } else {
            newCamera = self.cameraWithPosition(position: .back)!
        }
        do{
            let newVideoInput = try AVCaptureDeviceInput(device: newCamera)//AVCaptureDeviceInput(device: newCamera, error: nil)
            captureSession.addInput(newVideoInput)
        }
        catch {
            print(error)
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        //let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(.builtInWideAngleCamera , for: AVMediaType.video , position: position)
        } else {
            // Fallback on earlier versions
            let devices = AVCaptureDevice.devices(for: AVMediaType.video)
            for device in devices {
                if (device as AnyObject).position == position {
                    return device as? AVCaptureDevice
                }
            }
        }
        
        return nil
    }
    
    
    @IBAction func cameraToogleAction(_ sender: Any) {
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        self.seconds = 0
        self.durationTxt.text = secondsToFormatTimeFull(second: 0)
        stopRecording()
        
        let currentCameraInput: AVCaptureInput = captureSession.inputs[0] as! AVCaptureInput
        captureSession.removeInput(currentCameraInput)
        var newCamera: AVCaptureDevice
        if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
            newCamera = self.cameraWithPosition(position: .front)!
        } else {
            newCamera = self.cameraWithPosition(position: .back)!
        }
        do{
            let newVideoInput = try AVCaptureDeviceInput(device: newCamera)//AVCaptureDeviceInput(device: newCamera, error: nil)
            captureSession.removeInput(activeInput)
            captureSession.addInput(newVideoInput)
            activeInput = newVideoInput
        }
        catch {
            print(error)
        }
    }
    
}

