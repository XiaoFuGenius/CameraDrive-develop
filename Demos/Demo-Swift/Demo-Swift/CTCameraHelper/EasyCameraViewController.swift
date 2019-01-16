//
//  EasyCameraViewController.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/13.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import Foundation

class EasyCameraViewController: UIViewController {

    open var ip: String = ""
    open var handler_log = { (log: NSString) in }

    var camera: CTCameraHelper = CTCameraHelper.shared()!
    var easyCamera: CTEasyCamera = CTEasyCamera.shared()!

    var cameraView: UIView = UIView()
    var ledMode: Int = 0

    var layerBtn: UIButton = UIButton()
    var captureBtn: UIButton = UIButton()
    var exitBtn: UIButton = UIButton()

    var displayView: UIView = UIView()
    var displayLayer: Bool = false
    var successCount: Int = 0
    var failureCount: Int = 0

    var loaded: Bool = false

    deinit {
        self.cameraView.removeFromSuperview()
        NSLog("【dealloc】%@", self)

        self.stopCamera()
        self.resetCameraAfterCtrDealloc()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        objc_sync_enter(self)

        if !self.loaded {
            self.loaded = true
            self.prepareForCameraStart()
            self.startCamera()
        }

        objc_sync_exit(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.black

        self.setupCameraView()
        self.setupMainButtons()
        self.setupDisplayView()
    }

    func setupCameraView() {
        let frame: CGRect = CGRect.init(origin: CGPoint.init(x: 0, y: 0),
                                        size: CGSize.init(width: XFWidth(), height: XFWidth()*16/9))
        self.cameraView = XFView(bgColor: UIColor.clear, frame: frame)
        self.view.addSubview(self.cameraView)
    }

    func setupDisplayView() {
        var frame: CGRect = CGRect.init(origin: CGPoint.init(x: 0, y: 0),
                                        size: CGSize.init(width: XFWidth(), height: XFHeight()))
        self.displayView = XFView(bgColor: UIColor.clear, frame: frame)

        frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0),
                            size: CGSize.init(width: XFWidth(), height: XFWidth()*16/9))
        let imageView: UIImageView = UIImageView.init(frame: frame)
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.displayView.addSubview(imageView)

        let btnWidth: CGFloat = (XFWidth()-15*2-20*2)/3
        let btnHeight: CGFloat = 45
        frame = CGRect.init(origin: CGPoint.init(x: 15, y: XFHeight()-15-btnHeight),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let backBtn: UIButton = self.setupButtonTitle(title: "Back", action: #selector(displayViewBackBtnClick(sender:)), frame: frame)
        self.displayView.addSubview(backBtn)

        frame = CGRect.init(origin: CGPoint.init(x: backBtn.xf_Right+20, y: XFHeight()-15-btnHeight),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let layerBtn: UIButton = self.setupButtonTitle(title: "Layer", action: #selector(displayViewLayerBtnClick(sender:)), frame: frame)
        self.displayView.addSubview(layerBtn)

        frame = CGRect.init(origin: CGPoint.init(x: layerBtn.xf_Right+20, y: XFHeight()-15-btnHeight),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let saveBtn: UIButton = self.setupButtonTitle(title: "Save", action: #selector(displayViewSaveBtnClick(sender:)), frame: frame)
        self.displayView.addSubview(saveBtn)

        frame = CGRect.init(origin: CGPoint.init(x: saveBtn.xf_Left, y: XFSafeTop()+(44-btnHeight)/2),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let apiTest1Btn: UIButton = self.setupButtonTitle(title: "ApiTest1", action: #selector(displayViewApiTest1BtnClick(sender:)), frame: frame)
        self.displayView.addSubview(apiTest1Btn)

        frame = CGRect.init(origin: CGPoint.init(x: saveBtn.xf_Left, y: apiTest1Btn.xf_Bottom+20),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let apiTest2Btn: UIButton = self.setupButtonTitle(title: "ApiTest2", action: #selector(displayViewApiTest2BtnClick(sender:)), frame: frame)
        self.displayView.addSubview(apiTest2Btn)

        self.displayView.alpha = 0.0
        self.view.addSubview(self.displayView)
    }

    func setupMainButtons() {
        let btnWidth: CGFloat = (XFWidth()-15*2-20*2)/3
        let btnHeight: CGFloat = 45

        var frame: CGRect = CGRect.init(origin: CGPoint.init(x: self.view.xf_Width-15-btnWidth,
                                                             y: self.view.xf_Height-15-btnHeight),
                                        size: CGSize.init(width: btnWidth, height: btnHeight))
        let exitBtn: UIButton = self.setupButtonTitle(title: "Exit", action: #selector(exitBtnClick(sender:)), frame: frame)
        self.view.addSubview(exitBtn)
        self.exitBtn = exitBtn

        frame = CGRect.init(origin: CGPoint.init(x: exitBtn.xf_Left-20-btnWidth, y: exitBtn.xf_Top),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let captureBtn: UIButton = self.setupButtonTitle(title: "Capture", action: #selector(captureBtnClick(sender:)), frame: frame)
        self.view.addSubview(captureBtn)
        self.captureBtn = captureBtn

        frame = CGRect.init(origin: CGPoint.init(x: captureBtn.xf_Left-20-btnWidth, y: exitBtn.xf_Top),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        let layerBtn: UIButton = self.setupButtonTitle(title: "Layer", action: #selector(layerBtnClick(sender:)), frame: frame)
        self.view.addSubview(layerBtn)
        self.layerBtn = layerBtn
    }

    func setupButtonTitle(title: NSString, action: Selector, frame: CGRect) -> UIButton {
        let button: UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = frame
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)

        button.setTitle(title as String, for: UIControl.State.normal)
        button.titleLabel?.font = XFFont(fontSize: 15.0)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(XFColor(rgbValue: 0xffffff, alpha: 1.0), for: UIControl.State.normal)

        button.xf_SetBackgroundColor(XFColor(rgbValue: 0xcecece, alpha: 1.0), for: UIControl.State.normal)
        button.xf_SetBackgroundColor(XFColor(rgbValue: 0x4d7bfe, alpha: 1.0), for: UIControl.State.selected)
        button.xf_SetBackgroundColor(XFColor(rgbValue: 0x4d7bfe, alpha: 0.75),
                                     for: [UIControl.State.selected, UIControl.State.highlighted])

        button.layer.cornerRadius = 3.0
        button.clipsToBounds = true

        button.isSelected = true
        return button
    }

    //MARK: > default actions <
    @objc func exitBtnClick(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func captureBtnClick(sender: UIButton) {
        let rgbName: String = self.GetFilePath(fileName: "rgbName")
        let plName: String = self.GetFilePath(fileName: "plName")

        if !self.DeleteFileAtPath(path: rgbName) || !self.DeleteFileAtPath(path: plName) {
            self.showAlertViewMsg(msg: "最近一次采集的图像数据缓存清除失败.")
        }

        self.updateActionButtonStatus(isActived: false)

        weak var weakSelf = self
        self.easyCamera.captureRgbFilePath(rgbName, plFilePath: plName) { (status, description) in
            DispatchQueue.main.async {
                weakSelf?.updateActionButtonStatus(isActived: true)

                if status != 0 {
                    weakSelf?.showAlertViewMsg(msg: description!)
                    return
                }

                let rgbNameX: String = weakSelf!.GetFilePath(fileName: "rgbName")
                let plNameX: String = weakSelf!.GetFilePath(fileName: "plName")

                let rgbData: Data = weakSelf!.ReadFileAtPath(path: rgbNameX)
                let plData: Data = weakSelf!.ReadFileAtPath(path: plNameX)

                if rgbData.count==0 || plData.count==0 {
                    weakSelf?.showAlertViewMsg(msg: "未成功获取照片数据，请重试.")
                    return
                }

                weakSelf?.displayLayer = false
                let imageView: UIImageView = weakSelf!.displayView.subviews.first as! UIImageView
                imageView.image = UIImage.init(data: rgbData)

                UIView.animate(withDuration: 0.3, animations: {
                    weakSelf?.displayView.alpha = 1.0
                }, completion: { (finished) in
                    //FIXME:
                })
            }
        }
    }

    @objc func layerBtnClick(sender: UIButton) {
        self.ledMode = self.ledMode == 0 ? 1 : 0
        self.camera.ledMode = Int32(self.ledMode)
    }

    func updateActionButtonStatus(isActived: Bool) {
        self.layerBtn.isSelected = isActived
        self.layerBtn.isUserInteractionEnabled = isActived
        self.captureBtn.isSelected = isActived
        self.captureBtn.isUserInteractionEnabled = isActived
    }

    //MARK: > displayView actions <
    @objc func displayViewBackBtnClick(sender: UIButton) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, animations: {
            weakSelf?.displayView.alpha = 0.0
        }, completion: nil)
    }

    @objc func displayViewLayerBtnClick(sender: UIButton) {
        let rgbName: String = self.GetFilePath(fileName: "rgbName")
        let plName: String = self.GetFilePath(fileName: "plName")

        self.displayLayer = !self.displayLayer

        let fileName: String = self.displayLayer ? plName: rgbName
        let imageView: UIImageView = self.displayView.subviews.first as! UIImageView
        imageView.image = UIImage.init(data: self.ReadFileAtPath(path: fileName))
    }

    @objc func displayViewSaveBtnClick(sender: UIButton) {
        //FIXME:
    }

    //MARK: 图像检测api，测试样例
    @objc func displayViewApiTest1BtnClick(sender: UIButton) {
        //FIXME:
    }

    @objc func displayViewApiTest2BtnClick(sender: UIButton) {
        //FIXME:
    }

    //MARK: > alert message <
    func showAlertViewMsg(msg: String) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            let alert: UIAlertController = UIAlertController.init(title: nil, message: msg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.cancel, handler: nil))
            weakSelf?.present(alert, animated: true, completion: nil)
        }
    }

    func displayLog(log: String) {
        NSLog("[%@] %@", self, log)
        self.handler_log(log as NSString)
    }

    //MARK: > file operation <
    func GetFilePath(fileName: String) -> String {
        let directoryPaths: NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        let documentDirectory: NSString = directoryPaths.firstObject as! NSString
        let filePath: String = documentDirectory.appendingPathComponent(fileName)
        return filePath
    }

    func ReadFileAtPath(path: String) -> Data {
        if FileManager.default.fileExists(atPath: path) {
            let url: URL = URL.init(fileURLWithPath: path)

            do {
                let fileData: Data = try Data.init(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
                return fileData
            } catch {}
        }

        return Data()
    }

    func DeleteFileAtPath(path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch {}
        }

        return false
    }

    //MARK:- CAMERA
    func prepareForCameraStart() {
        self.camera.renderingBitrate = 800
        self.camera.ledMode = 0
        self.camera.isRetroflexion = true
        self.camera.ip = self.ip
        self.camera.port = 1000
        self.camera.loadBearerView(self.cameraView) { (status, description) in
            NSLog("%@", description!)
        }
    }

    func resetCameraAfterCtrDealloc() {
        self.camera.unloadBearerView { (status, description) in
            NSLog("%@", description!)
        }
    }

    func startCamera() {
        weak var weakSelf = self

        self.easyCamera.startLoadingHnadler = { () in
            DispatchQueue.main.async {
                weakSelf?.updateActionButtonStatus(isActived: false)
            }
        }

        self.easyCamera.startTimeoutHandler = { () in
            DispatchQueue.main.async {
                weakSelf?.cameraStartTimeoutHandler()
            }
        }

        self.easyCamera.captureTimeoutHandler = { () in
            DispatchQueue.main.async {
                weakSelf?.captureTimeoutHandler()
            }
        }

        self.easyCamera.start { (status, description) in
            DispatchQueue.main.async {
                NSLog("%@", description!)

                weakSelf?.cameraStatusUpdate(isOK: status==0)
            }
        }
    }

    func stopCamera() {
        self.easyCamera.stop { (status, description) in
            NSLog("%@", description!);
        }
    }

    func cameraStatusUpdate(isOK: Bool) {
        if !isOK {
            self.showAlertViewMsg(msg: "摄像头发生错误，当前已关闭，可尝试重启或者退出当前控制器.")
            return
        }

        NSLog("摄像头 当前已启动.")
        self.camera.ledMode = Int32(self.ledMode)
        self.updateActionButtonStatus(isActived: true)
    }

    func cameraInterruptedHandler() {
        self.showAlertViewMsg(msg: "测肤仪断开连接,请重新连接")
    }

    func cameraStartTimeoutHandler() {
        self.showAlertViewMsg(msg: "摄像头启动失败，可继续等待或退出并重启测肤仪后再次连接")
    }

    func captureTimeoutHandler() {
        self.showAlertViewMsg(msg: "图像采集失败，请再试一次吧")
    }

}
