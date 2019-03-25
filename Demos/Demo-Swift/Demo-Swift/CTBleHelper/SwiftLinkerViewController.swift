//
//  SwiftLinkerViewController.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/12.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import Foundation

class SwiftLinkerViewController: UIViewController {

    private var start: UIButton = UIButton()
    private var stop: UIButton = UIButton()
    private var getInfo: UIButton = UIButton()
    private var startCamera: UIButton = UIButton()
    private var startBleUpgrade: UIButton = UIButton()
    private var startCoreUpgrade: UIButton = UIButton()
    private var setWiredMode: UIButton = UIButton()
    private var calibration: UIButton = UIButton()
    private var shutdown: UIButton = UIButton()
    private var maskView: UIView = UIView()

    private var bleActived = false

    private var log: NSMutableString = NSMutableString()
    private var textView: UITextView = UITextView()

    private var upgradeValue: Int32 = 0
    private var shouldReset = false  // 用于判定是否进入图像采集控制器

    //MARK:- LIFE CYCLE
    deinit {
        //NSLog("【dealloc】%@", self)
        print("【dealloc】\(self)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        shouldReset = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if shouldReset {
            self.stop(sender: self.stop)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.navigationBar.isTranslucent = false

        self.title = "SwiftLinker";
        self.view.backgroundColor = UIColor.XF_f6Gray

        self.customUI()
        self.everythingIsReady()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }

    // MARK:- >> sdk 基础配置 <<
    func everythingIsReady() {
        CTSwiftLinker.shared()  // 必须要最先调用，以激活通知注册
        NotificationCenter.default.removeObserver(self, name: .CTSwift_iPhone_BleUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CTSwift_iPhone_BleUpdate(noti:)), name: .CTSwift_iPhone_BleUpdate, object: nil)

        if CTBleHelper.blePowerdOn() == -1 {
            self.xf_Log(logX: "等待< 用户给予蓝牙权限 >或< Sdk内部启动蓝牙模块 >.")
            bleActived = false
            return
        }
        bleActived = true

        self.xf_Log(logX: "准备就绪...")
        self.configXiaoFuSdk()
        self.resetUI()

        if CTBleHelper.blePowerdOn() == 0 {
            self.xf_Log(logX: "手机蓝牙已关闭.")
            return
        }
        self.xf_Log(logX: "手机蓝牙已打开.")
    }

    func configXiaoFuSdk() {
        weak var weakSelf = self

        CTSwiftLinker.shared().configHandler = { () in
            CTConfig.shared()?.debugEnable = true
            CTConfig.shared()?.debugLogType = 1
            CTConfig.shared()?.debugLogHandler = { (log: String?) in
                weakSelf?.xf_Log(logX: log! as NSString)
            }
            CTConfig.shared()?.blueStripDetectionHandler = { (blueStripImage:UIImage?) in
                weakSelf?.xf_Log(logX: "当前图片检测到蓝条，可选择记录日志或者图片数据。")
            }  // 1.0.17 新增，蓝条检测
            //CTConfig.shared()?.blueStripDetectionType = 1
            CTConfig.shared()?.channelSetting = -1  // 1.0.17 新增，AP模式，随机信道
            CTConfig.shared()?.splitStrings = ["!@"]

            CTEasyLinker.sharedEsay().smartMode = 1
            CTEasyLinker.sharedEsay().verify5GEnabled = true
            CTEasyLinker.sharedEsay().staPingEnabled = true
            CTEasyLinker.sharedEsay().staCachesStored = true
            CTEasyLinker.sharedEsay().ssidIgnored = ["CFY_"]
            CTEasyLinker.sharedEsay().hotspotEnabled = true
        }

        CTSwiftLinker.shared().bleResponse = { (status, description) in
            DispatchQueue.main.async {
                weakSelf?.bleResponseStatus(status: status, description: description)
            }
        }

        CTSwiftLinker.shared().networkResponse = { (status, description) in
            DispatchQueue.main.async {
                weakSelf?.networkResponseStatus(status: status, description: description)
            }
        }

        CTSwiftLinker.shared().alertShowHandler = { (type: Int32, ssid) in
            DispatchQueue.main.async {
                weakSelf?.alertShowHandlerType(type: Int(type), ssid: ssid)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(CTSwift_Device_BatteryUpdate(noti:)), name: .CTSwift_Device_BatteryUpdate, object: nil)
    }

    func bleResponseStatus(status: CTSwiftBleLinkStatus, description: String?) {
        switch status {
        case CTSwiftBleLinkStatus.devicePoweredOn:
            self.xf_Log(logX: description! as NSString)
        case CTSwiftBleLinkStatus.deviceNotFound, CTSwiftBleLinkStatus.deviceFailed:
            self.xf_Log(logX: description! as NSString)
            self.resetUI()
        case CTSwiftBleLinkStatus.deviceConnecting:
            self.xf_Log(logX: description! as NSString)
        case CTSwiftBleLinkStatus.deviceSucceed:
            self.xf_Log(logX: "已连接设备蓝牙，开始尝试与设备建立网络连接.")

            let device: Dictionary<String, AnyObject> = CTBleHelper.deviceInfoCache() as! Dictionary<String, AnyObject>
            let deviceInfo: NSString = NSString.init(format: "%@，%@，%d，ble：%@，core：%@ .",
                                                     device["Name"] as! CVarArg, device["BindID"] as! CVarArg,
                                                     (device["RSSI"] as! NSNumber).intValue,
                                                     device["BleVersionString"] as! CVarArg,
                                                     device["CoreVersionString"] as! CVarArg)

            self.xf_Log(logX: deviceInfo)

            self.title = deviceInfo.components(separatedBy: "，ble").first
            self.updateUI4BleConnected()

            CTSwiftLinker.startNetworkLink()
        }
    }

    func networkResponseStatus(status: CTSwiftNetworkLinkStatus, description: String?) {
        switch status {
        case CTSwiftNetworkLinkStatus.linkCheckStatus, CTSwiftNetworkLinkStatus.linkSTA,
             CTSwiftNetworkLinkStatus.link5gChecking, CTSwiftNetworkLinkStatus.linkWiFiStart,
             CTSwiftNetworkLinkStatus.linkPwdError, CTSwiftNetworkLinkStatus.linkPingChecking,
             CTSwiftNetworkLinkStatus.linkAP, CTSwiftNetworkLinkStatus.linkHotspotStart,
             CTSwiftNetworkLinkStatus.linkIpAddrChecking:
            self.xf_Log(logX: description! as NSString)
        case CTSwiftNetworkLinkStatus.linkStaFailed, CTSwiftNetworkLinkStatus.linkSsidNotFound,
             CTSwiftNetworkLinkStatus.linkApFailed:
            self.xf_Log(logX: description! as NSString)
            self.maskView.isHidden = true
        case CTSwiftNetworkLinkStatus.link5gConfirmed:
            self.xf_Log(logX: description! as NSString)

            let alert5G: UIAlertController = UIAlertController(title: "5g检查，判定为5g网络",
                                                               message: "设备 当前“不支持”5G网络 联网，请使用AP模式联网或重试.",
                                                               preferredStyle: .alert)
            alert5G.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
            self.showAlert(alert: alert5G, sender: self.start)

            self.maskView.isHidden = true
        case CTSwiftNetworkLinkStatus.linkPingFailed:
            self.xf_Log(logX: description! as NSString)

            let alertPing = UIAlertController(title: "ping检查，判定为公共验证类wifi",
                                            message: "设备 当前“不支持”公共验证类wifi 联网，请使用AP模式联网或重试.",
                                            preferredStyle: .alert)
            alertPing.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
            self.showAlert(alert: alertPing, sender: self.start)

            self.maskView.isHidden = true
        case CTSwiftNetworkLinkStatus.linkSucceed:
            let msg: NSString = NSString.init(format: "设备已联网(%@，ip：%@).", CTSwiftLinker.shared().type == 1 ? "STA模式" : "AP模式", CTSwiftLinker.shared().ip)
            self.xf_Log(logX: msg)

            self.startCamera.isUserInteractionEnabled = true
            self.startCamera.isSelected = true
            self.startCoreUpgrade.isUserInteractionEnabled = true
            self.startCoreUpgrade.isSelected = true

            self.maskView.isHidden = true
        case CTSwiftNetworkLinkStatus.linkFailed:
            self.xf_Log(logX: description! as NSString)
            //self.xf_Log(logX: "设备联网失败，请重新尝试(若多次联网失败，建议先重启设备).")
            self.maskView.isHidden = true
        }
    }

    func alertShowHandlerType(type: Int, ssid: String?) {
        if type == 1 {
            self.showSTALinkAlert(ssid: ssid ?? "")
        } else {
            self.showAPLinkAlert(ssid: ssid ?? "")
        }
    }

    @objc func CTSwift_iPhone_BleUpdate(noti: Notification) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            objc_sync_enter(weakSelf as Any)

            if (weakSelf?.bleActived)! {
                if CTBleHelper.blePowerdOn() == 0 {
                    weakSelf?.xf_Log(logX: "手机蓝牙已关闭.")
                } else {
                    weakSelf?.xf_Log(logX: "手机蓝牙已打开.")
                }
                return
            }

            // 用户已授权 & Sdk内部蓝牙模块已启动.
            weakSelf?.bleActived = true
            weakSelf?.everythingIsReady()

            objc_sync_exit(weakSelf as Any)
        }
    }

    @objc func CTSwift_Device_BatteryUpdate(noti: Notification) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            let batteryInfo: Dictionary<String, AnyObject> = noti.userInfo as! Dictionary<String, AnyObject>
            let success: Bool = (batteryInfo["Success"] as! NSNumber).boolValue
            let isCharge: Bool = (batteryInfo["IsCharge"] as! NSNumber).boolValue
            let battery: Int = (batteryInfo["Battery"] as! NSNumber).intValue

            if success {
                let info: NSString = NSString.init(format: "收到电量状态变化通知，设备%@，电量：%d.",
                                                   isCharge ? "正在充电" : "未充电", battery)
                weakSelf?.xf_Log(logX: info)
            } else {
                weakSelf?.xf_Log(logX: "电量信息请求失败.")
            }
        }
    }

    // MARK: > STA Mode <
    func showSTALinkAlert(ssid: String) {
        if ssid.isEmpty {
            self.xf_Log(logX: "showSTALinkAlert，启动失败，未获取到ssid.")
            self.resetUI()
            return
        }

        //weak var weakSelf = self

        let staAlert: UIAlertController = UIAlertController(title: "输入wifi密码", message: ssid, preferredStyle: .alert)
        staAlert.addTextField(configurationHandler: { textField in
            //可自定义textField相关属性...
        })
        staAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
            CTSwiftLinker.shared().canceledHandler!()
        }))
        staAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            let pwd = staAlert.textFields?.first?.text
            CTSwiftLinker.shared().confirmedHandler!(pwd!)
        }))
        self.showAlert(alert: staAlert, sender: self.start)
    }

    //MARK: > AP Mode <
    func showAPLinkAlert(ssid: String) {
        if ssid.isEmpty {
            self.xf_Log(logX: "showAPLinkAlert，启动失败，未获取到ssid.")
            self.resetUI()
            return
        }

        //weak var weakSelf = self

        let apAlert: UIAlertController = UIAlertController.init(title: "前往设置连接指定热点", message: ssid, preferredStyle: UIAlertController.Style.alert)
        apAlert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel,
                                             handler: { (action: UIAlertAction) in
            CTSwiftLinker.shared().canceledHandler!()
        }))
        apAlert.addAction(UIAlertAction.init(title: "前往", style: UIAlertAction.Style.default,
                                             handler: { (action: UIAlertAction) in
            CTSwiftLinker.shared().confirmedHandler!("")
        }))
        self.showAlert(alert: apAlert, sender: self.start)
    }

    //MARK:- >> Additional <<
    //MARK: > for getInfo <
    func wifiStatus() {
        self.xf_Log(logX: "[仅检查]开始获取设备网络状态...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTEasyLinker.networkStatusCheckOnly(true) { (code, type, ssid, password, ip) in
            DispatchQueue.main.async {
                weakSelf?.maskView.isHidden = true

                var logMsg: String = "wifiStatus 获取成功."
                if code == CTBleResponseCode.error {
                    logMsg = "未成功获取 wifiStatus."
                    weakSelf?.xf_Log(logX: logMsg as NSString)
                    return
                }

                weakSelf?.xf_Log(logX: logMsg as NSString)
                if type == 0 {
                    if (CTConfig.getSSID()?.isEmpty)! {
                        logMsg = "UnKnown_手机未连接wifi，可启动ap模式.";
                    } else {
                        logMsg = "UnKnown_手机已连接wifi，可启动sta模式.";
                    }
                } else if type == 1 {
                    if (CTConfig.getSSID() as NSString).isEqual(to: ssid) {
                        if ip.isEmpty {
                            logMsg = "AP_手机已连接设备热点，但未获取到设备联网ip，可启动sta模式.";
                        } else {
                            logMsg = "STA_手机与设备处于同一wifi网络，且已获取到设备联网ip，可直接启动摄像头.";
                        }
                    } else {
                        logMsg = "STA_手机已连接wifi，可启动sta模式.";
                    }
                } else if type == 2 {
                    if (CTConfig.getSSID()?.isEmpty)! {
                        logMsg = "AP_手机未连接wifi，可启动ap模式.";
                    } else {
                        if (CTConfig.getSSID() as NSString).isEqual(to: ssid) {
                            if ip.isEmpty {
                                logMsg = "AP_手机已连接设备热点，但未获取到设备联网ip，可启动ap模式.";
                            } else {
                                logMsg = "AP_手机已连接设备热点，且已获取到设备联网ip，可直接启动摄像头.";
                            }
                        } else {
                            logMsg = "AP_手机未连接当前设备热点，可启动ap模式.";
                        }
                    }
                }
                weakSelf?.xf_Log(logX: logMsg as NSString)
            }
        }
    }

    func getMAC() {
        self.xf_Log(logX: "开始获取设备的 MAC信息...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTBleHelper.mac { (code, mac) in
            DispatchQueue.main.async {
                weakSelf?.maskView.isHidden = true
                if code == CTBleResponseCode.OK {
                    weakSelf?.xf_Log(logX: NSString.init(format: "MAC信息获取成功：%@.", mac!))
                } else {
                    weakSelf?.xf_Log(logX: "MAC信息获取失败.")
                }
            }
        }
    }

    func getVersion() {
        self.xf_Log(logX: "开始获取设备的 Version信息...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTBleHelper.version { (code, ble, core, bleValue, coreValue) in
            DispatchQueue.main.async {
                weakSelf?.maskView.isHidden = true
                if code == CTBleResponseCode.OK {
                    let verInfo: NSString = NSString.init(format: "Version获取成功：Ble:%@[%ld], Core：%@[%ld].", ble!, bleValue, core!, coreValue)
                    weakSelf?.xf_Log(logX: verInfo)
                } else {
                    weakSelf?.xf_Log(logX: "Version信息获取失败.")
                }
            }
        }
    }

    func getBattery() {
        self.xf_Log(logX: "开始获取设备的 Battery信息...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTBleHelper.battery { (code, isCharge, battery) in
            DispatchQueue.main.async {
                weakSelf?.maskView.isHidden = true
                if code == CTBleResponseCode.OK {
                    let batteryInfo: NSString = NSString.init(format: "Battery获取成功：isCharge：%d, battery：%d.", isCharge, battery)
                    weakSelf?.xf_Log(logX: batteryInfo)
                } else {
                    weakSelf?.xf_Log(logX: "Battery信息获取失败.")
                }
            }
        }
    }

    //MARK: > for ble upgrade <
    func bleVersionUpgradeLimitedTargetVersion(targetVersion: Int, completion: (() -> Void)?) {
        let bleVersion: Int = (CTBleHelper.deviceInfoCache()!["BleVersion"] as! NSNumber).intValue
        let coreVersion: Int = (CTBleHelper.deviceInfoCache()!["CoreVersion"] as! NSNumber).intValue

        var limited: Bool = false
        var alertMsg: String = "蓝牙固件版本受限处理."
        // 受限判定
        if bleVersion > 20000 && coreVersion > 30000 && targetVersion < 20100 {
            // ble > 2.0.0，core > 3.0.0，降级操作：目标版本2.0.0 + 3.0.0，必须先核心，后蓝牙
            limited = true
            alertMsg = "请先降级核心固件版本."
        }

        if !limited {  // 无受限
            completion?()
            return
        }

        // 显示受限警示框
        let alert: UIAlertController = UIAlertController.init(title: alertMsg, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default, handler: nil))
        self .showAlert(alert: alert, sender: self.startBleUpgrade)
    }

    func startUpdateBle(verName: NSString) {
        let targetStr: NSString = verName.components(separatedBy: "_")[1] as NSString
        let bleVers: Array = targetStr.components(separatedBy: ".")
        let target: Int = Int(bleVers[0])!*10000 + Int(bleVers[1])!*100 + Int(bleVers[2])!

        weak var weakSelf = self
        self.bleVersionUpgradeLimitedTargetVersion(targetVersion: target) {
            weakSelf?.xf_Log(logX: "开始升级蓝牙固件...")
            weakSelf?.maskView.isHidden = false

            do {
                let url: URL = URL.init(fileURLWithPath: Bundle.main.path(forResource: verName as String, ofType: "bin")!)
                let bleData: Data = try Data.init(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)

                weakSelf?.upgradeValue = -1
                CTEasyLinker.updateBLE(bleData, response: { (code, value, msg) in
                    DispatchQueue.main.async {
                        if code == CTBleResponseCode.error {
                            weakSelf?.maskView.isHidden = true
                            weakSelf?.xf_Log(logX: NSString.init(format: "升级失败：%@", msg))
                            weakSelf?.resetUI()
                            return
                        }

                        if value < 100 {
                            if value < 3 || value > 97 {
                                weakSelf?.xf_Log(logX: NSString.init(format: "升级进度：%d（%@）", value, msg))
                            } else if value == 3 ||
                                value == 16 || value == 26 || value == 36 || value == 56 ||
                                value == 66 || value == 76 || value == 86 || value == 96 {
                                if weakSelf?.upgradeValue != value {
                                    weakSelf?.upgradeValue = value
                                    weakSelf?.xf_Log(logX: NSString.init(format: "升级进度：%d（%@）", value, msg))
                                }
                            }
                        } else {
                            weakSelf?.maskView.isHidden = true
                            weakSelf?.xf_Log(logX: NSString.init(format: "升级进度：%d（%@）", value, msg))
                            weakSelf?.resetUI()
                        }
                    }
                })

            } catch { }
        }
    }

    //MARK: > for core upgrade <
    func coreVersionUpgradeLimitedTargetVersion(targetVersion: Int, completion: (() -> Void)?) {
        let bleVersion: Int = (CTBleHelper.deviceInfoCache()!["BleVersion"] as! NSNumber).intValue
        //let coreVersion: Int = (CTBleHelper.deviceInfoCache()!["CoreVersion"] as! NSNumber).intValue

        var limited: Bool = false
        var alertMsg: String = "核心固件版本受限处理."
        // 受限判定
        if bleVersion < 20100 && targetVersion > 30000 {
            // ble < 2.1.0，升级操作：目标版本2.1.0 + 3.1.0，必须先蓝牙，后核心
            limited = true
            alertMsg = "请先升级蓝牙固件版本."
        }

        if !limited {  // 无受限
            completion?()
            return
        }

        // 显示受限警示框
        let alert: UIAlertController = UIAlertController.init(title: alertMsg, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default, handler: nil))
        self .showAlert(alert: alert, sender: self.startBleUpgrade)
    }

    func startUpdateCore(verName: NSString) {
        let targetStr: NSString = verName.components(separatedBy: "_")[1] as NSString
        let bleVers: Array = targetStr.components(separatedBy: ".")
        let target: Int = Int(bleVers[0])!*10000 + Int(bleVers[1])!*100 + Int(bleVers[2])!

        weak var weakSelf = self
        self.coreVersionUpgradeLimitedTargetVersion(targetVersion: target) {
            weakSelf?.xf_Log(logX: "开始升级核心固件...")
            weakSelf?.maskView.isHidden = false

            do {
                let url: URL = URL.init(fileURLWithPath: Bundle.main.path(forResource: verName as String, ofType: "bin")!)
                let coreData: Data = try Data.init(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)

                weakSelf?.upgradeValue = -1
                CTEasyLinker.updateCore(coreData, response: { (code, value, msg) in
                    DispatchQueue.main.async {
                        if code == CTBleResponseCode.error {
                            weakSelf?.maskView.isHidden = true
                            weakSelf?.xf_Log(logX: NSString.init(format: "升级失败：%@", msg))
                            weakSelf?.shutdown(sender: UIButton())
                            return
                        }

                        if value < 100 {
                            if value < 6 || value > 97 {
                                weakSelf?.xf_Log(logX: NSString.init(format: "升级进度：%d（%@）", value, msg))
                            } else if value == 3 ||
                                value == 16 || value == 26 || value == 36 || value == 56 ||
                                value == 66 || value == 76 || value == 86 || value == 96 {
                                if weakSelf?.upgradeValue != value {
                                    weakSelf?.upgradeValue = value
                                    weakSelf?.xf_Log(logX: NSString.init(format: "升级进度：%d（%@）", value, msg))
                                }
                            }
                        } else {
                            weakSelf?.maskView.isHidden = true
                            weakSelf?.xf_Log(logX: NSString.init(format: "升级进度：%d（%@）", value, msg))
                            weakSelf?.shutdown(sender:UIButton())
                        }
                    }
                })

            } catch { }
        }
    }

    //MARK: > for calibration <
    func calibrationAction() {
        let bleVersion: Int = (CTBleHelper.deviceInfoCache()!["BleVersion"] as! NSNumber).intValue
        let coreVersion: Int = (CTBleHelper.deviceInfoCache()!["CoreVersion"] as! NSNumber).intValue

        if bleVersion < 20100 || coreVersion < 30100 {
            self.xf_Log(logX: "固件版本不符合要求，已取消.")
            return
        }

        self.xf_Log(logX: "开始检查当前校准状态...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTBleHelper.calibrateStatusCheck { (code, status, msg) in
            DispatchQueue.main.async {
                weakSelf?.maskView.isHidden = true
                if code == CTBleResponseCode.error {
                    weakSelf?.xf_Log(logX: "获取校准状态 请求失败.")
                    return
                }

                if -1 == status {
                    weakSelf?.xf_Log(logX: "校准状态未知.")
                } else if 0 == status {
                    weakSelf?.xf_Log(logX: "当前设备不需要校准.")
                } else if 1 == status {
                    weakSelf?.xf_Log(logX: "请使用专门的 校准工具 进行校准.")
                } else if 2 == status {
                    weakSelf?.xf_Log(logX: "当前设备已校准.")
                }
            }
        }
    }

    func recalibration() {
        let bleVersion: Int = (CTBleHelper.deviceInfoCache()!["BleVersion"] as! NSNumber).intValue
        let coreVersion: Int = (CTBleHelper.deviceInfoCache()!["CoreVersion"] as! NSNumber).intValue

        if bleVersion < 20100 || coreVersion < 30100 {
            self.xf_Log(logX: "固件版本不符合要求，已取消.")
            return
        }

        self.xf_Log(logX: "开始检查当前校准状态...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTBleHelper.calibrateStatusCheck { (code, status, msg) in
            DispatchQueue.main.async {
                if code == CTBleResponseCode.error {
                    weakSelf?.maskView.isHidden = true
                    weakSelf?.xf_Log(logX: "获取校准状态 请求失败.")
                    return
                }

                if 2 == status {
                    weakSelf?.xf_Log(logX: "设备已校准，开始执行 图像校准回滚...")
                    CTBleHelper.calibrateCommand(3, response: { (code, status, msg) in
                        DispatchQueue.main.async {
                            weakSelf?.xf_Log(logX: NSString.init(format: "图像校准回滚：%@.", msg!))
                            weakSelf?.maskView.isHidden = true
                            if code == CTBleResponseCode.OK {
                                weakSelf?.shutdown(sender: UIButton())
                            }
                        }
                    })
                    return
                }

                weakSelf?.maskView.isHidden = true
                if -1 == status {
                    weakSelf?.xf_Log(logX: "校准状态未知，回滚拒绝.")
                } else if 0 == status {
                    weakSelf?.xf_Log(logX: "当前设备不需要校准，回滚拒绝.")
                } else if 1 == status {
                    weakSelf?.xf_Log(logX: "当前设备未校准，回滚拒绝.")
                } else if 2 == status {
                    //weakSelf?.xf_Log(logX: "当前设备已校准，可以回滚.")
                }
            }
        }
    }

    func restartNVDS() {
        let bleVersion: Int = (CTBleHelper.deviceInfoCache()!["BleVersion"] as! NSNumber).intValue
        let coreVersion: Int = (CTBleHelper.deviceInfoCache()!["CoreVersion"] as! NSNumber).intValue

        if bleVersion < 20100 || coreVersion < 30100 {
            self.xf_Log(logX: "固件版本不符合要求，已取消.")
            return
        }

        self.xf_Log(logX: "开始执行 一键恢复，校准配置...")
        self.maskView.isHidden = false

        weak var weakSelf = self
        CTBleHelper.calibrateRestartNVDS { (code, status, msg) in
            DispatchQueue.main.async {
                weakSelf?.xf_Log(logX: NSString.init(format: "一键恢复，校准配置：%@", msg!))
                weakSelf?.maskView.isHidden = true
                if code == CTBleResponseCode.OK {
                    weakSelf?.shutdown(sender: UIButton())
                }
            }
        }
    }

    //MARK: > for setWireMode <
    func setWiredMode(mode: Int) {
        weak var weakSelf = self

        let alert: UIAlertController = UIAlertController.init(title: "请选择设备类型", message: nil,
                                                              preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction.init(title: "老设备", style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
            CTBleHelper.setWiredModeCommand(Int32(-mode), response: { (code, msg) in
                DispatchQueue.main.async {
                    let modeDes: String = mode == 1 ? "混合" : (mode == 2 ? "无线" : "有线")
                    if code == CTBleResponseCode.OK {
                        weakSelf?.xf_Log(logX: NSString.init(format: "老设备 %@模式 设置成功.", modeDes))
                    } else {
                        weakSelf?.xf_Log(logX: NSString.init(format: "老设备 %@模式 设置失败.", modeDes))
                    }
                    weakSelf?.shutdown(sender: UIButton())
                }
            })
        }))
        alert.addAction(UIAlertAction.init(title: "新设备", style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
            CTBleHelper.setWiredModeCommand(Int32(mode), response: { (code, msg) in
                DispatchQueue.main.async {
                    let modeDes: String = mode == 1 ? "混合" : (mode == 2 ? "无线" : "有线")
                    if code == CTBleResponseCode.OK {
                        weakSelf?.xf_Log(logX: NSString.init(format: "新设备 %@模式 设置成功.", modeDes))
                    } else {
                        weakSelf?.xf_Log(logX: NSString.init(format: "新设备 %@模式 设置失败.", modeDes))
                    }
                    weakSelf?.shutdown(sender: UIButton())
                }
            })
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel,
                                           handler:nil))
        self.showAlert(alert: alert, sender: self.setWiredMode)
    }

    // MARK:- >> customUI <<
    func customUI() {
        var frame = CGRect.init(x: 0, y: 0, width: XFWidth(), height: XFHeight()-XFNaviBarHeight())
        let mainView: UIView = XFView(bgColor: UIColor.clear, frame: frame)
        self.view.addSubview(mainView)

        var top: CGFloat = 5.0
        frame = CGRect.init(x: 5, y: top, width: mainView.xf_Width-10, height: mainView.xf_Height/2-10)
        // NSTextStorage, NSLayoutManager, NSTextContainer
        let textView: UITextView = UITextView.init(frame: frame)
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = XFColor(rgbValue: 0x333333, alpha: 1.0).cgColor
        textView.layer.cornerRadius = 3.0
        textView.clipsToBounds = true
        textView.font = XFFont(fontSize: 11.0)
        textView.textColor = XFColor(rgbValue: 0x333333, alpha: 1.0)

        textView.isEditable = false
        //textView.isSelectable = false;  // iOS 11 + 会触发 滚动至最后一行 功能出现Bug；

        textView.layoutManager.allowsNonContiguousLayout = false
        mainView.addSubview(textView)
        top += textView.xf_Height+15
        self.textView = textView

        frame = CGRect.init(x: 5, y: top-10, width: mainView.xf_Width-10, height: mainView.xf_Height-5-(top-10))
        let maskView: UIView = XFView(bgColor: XFColor(rgbValue: 0x000000, alpha: 0.3), frame: frame)
        maskView.layer.cornerRadius = 3.0
        maskView.isHidden = true
        self.maskView = maskView


        let btnWidth: CGFloat = (XFWidth()-15*2-20*2)/3
        let btnHeight: CGFloat = 45
        let limitHeight: CGFloat = mainView.xf_Height
        var left: CGFloat = 15
        let spacing: CGFloat = 10

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.start = self.setupButtonTitle(title: "start",
                                           action: #selector(start(sender:)), frame: frame)
        self.view.addSubview(self.start)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.stop = self.setupButtonTitle(title: "stop",
                                          action: #selector(stop(sender:)), frame: frame)
        self.view.addSubview(self.stop)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.getInfo = self.setupButtonTitle(title: "getInfo", action: #selector(getInfo(sender:)), frame: frame)
        self.view.addSubview(self.getInfo)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.startBleUpgrade = self.setupButtonTitle(title: "startBleUpgrade", action: #selector(startBleUpgrade(sender:)), frame: frame)
        self.view.addSubview(self.startBleUpgrade)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.startCamera = self.setupButtonTitle(title: "startCamera", action: #selector(startCamera(sender:)), frame: frame)
        self.view.addSubview(self.startCamera)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.startCoreUpgrade = self.setupButtonTitle(title: "startCoreUpgrade", action: #selector(startCoreUpgrade(sender:)), frame: frame)
        self.view.addSubview(self.startCoreUpgrade)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.calibration = self.setupButtonTitle(title: "calibration", action: #selector(calibrationTools(sender:)), frame: frame)
        self.view.addSubview(self.calibration)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.setWiredMode = self.setupButtonTitle(title: "wiredMode", action: #selector(wiredMode(sender:)), frame: frame)
        self.view.addSubview(self.setWiredMode)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        frame = CGRect.init(origin: CGPoint.init(x: Int(left), y: Int(top)),
                            size: CGSize.init(width: btnWidth, height: btnHeight))
        self.shutdown = self.setupButtonTitle(title: "shutdown", action: #selector(shutdown(sender:)), frame: frame)
        self.view.addSubview(self.shutdown)
        top += btnHeight+spacing
        if top+btnHeight+spacing > limitHeight {
            left += btnWidth+20
            top = self.start.xf_Top
        }

        self.view.addSubview(self.maskView)
    }

    func setupButtonTitle(title: NSString, action: Selector, frame: CGRect) -> UIButton {
        let button: UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = frame
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)

        button.setTitle(title as String, for: UIControl.State.normal)
        button.titleLabel?.font = XFFont(fontSize: 15.0)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(XFColor(rgbValue: 0xffffff, alpha: 1.0), for: UIControl.State.normal)

        button.xf_SetBackgroundColor(XFColor(rgbValue: 0xcecece, alpha: 1.0), for: UIControl.State.normal)
        button.xf_SetBackgroundColor(XFColor(rgbValue: 0x4d7bfe, alpha: 1.0), for: UIControl.State.selected)
        button.xf_SetBackgroundColor(XFColor(rgbValue: 0x4d7bfe, alpha: 0.75),
                                     for: [UIControl.State.selected, UIControl.State.highlighted])

        button.layer.cornerRadius = 3.0
        button.clipsToBounds = true

        button.isSelected = false
        return button
    }

    func resetUI() {
        self.maskView.isHidden = true

        self.title = "CTSwiftLinker"
        self.start.isUserInteractionEnabled = true
        self.start.isSelected = true
        self.stop.isUserInteractionEnabled = false
        self.stop.isSelected = false

        self.shutdown.isUserInteractionEnabled = false
        self.shutdown.isSelected = false

        self.getInfo.isUserInteractionEnabled = false
        self.getInfo.isSelected = false
        self.startBleUpgrade.isUserInteractionEnabled = false
        self.startBleUpgrade.isSelected = false

        self.setWiredMode.isUserInteractionEnabled = false
        self.setWiredMode.isSelected = false
        self.calibration.isUserInteractionEnabled = false
        self.calibration.isSelected = false

        self.startCamera.isUserInteractionEnabled = false
        self.startCamera.isSelected = false
        self.startCoreUpgrade.isUserInteractionEnabled = false
        self.startCoreUpgrade.isSelected = false
    }

    func updateUI4BleConnected() {
        self.start.isUserInteractionEnabled = false
        self.start.isSelected = false
        self.stop.isUserInteractionEnabled = true
        self.stop.isSelected = true

        self.shutdown.isUserInteractionEnabled = true
        self.shutdown.isSelected = true

        self.getInfo.isUserInteractionEnabled = true
        self.getInfo.isSelected = true
        self.startBleUpgrade.isUserInteractionEnabled = true
        self.startBleUpgrade.isSelected = true

        self.setWiredMode.isUserInteractionEnabled = true
        self.setWiredMode.isSelected = true
        self.calibration.isUserInteractionEnabled = true
        self.calibration.isSelected = true

        self.startCamera.isUserInteractionEnabled = false
        self.startCamera.isSelected = false
        self.startCoreUpgrade.isUserInteractionEnabled = false
        self.startCoreUpgrade.isSelected = false
    }

    func getAlertStyle(style: UIAlertController.Style) -> UIAlertController.Style {
        if UIDevice.xf_DeviceType()==XFDeviceType.iPad {
            return UIAlertController.Style.alert
        }
        return style
    }

    func showAlert(alert: UIAlertController, sender: UIView) {
        if UIDevice.xf_DeviceType()==XFDeviceType.iPad {
            let popPresenter: UIPopoverPresentationController = alert.popoverPresentationController!
            popPresenter.sourceView = sender
            popPresenter.sourceRect = sender.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: >> Log <<
    func xf_Log(logX: NSString) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            let formatter: DateFormatter = DateFormatter.init()
            formatter.dateFormat = "[HH:mm:ss.SSS]："
            let date: NSString = formatter.string(from: NSDate() as Date) as NSString

            weakSelf?.log.appendFormat("%@%@\r\n", date, logX)
            NSLog("%@%@\r\n", date, logX)

            weakSelf?.textView.text = weakSelf?.log as String?
            weakSelf?.textView.scrollRangeToVisible(NSRange.init(location: (weakSelf?.textView.text.count)!, length: 1))
        }
    }

    // MARK:- >> Actions <<

    @objc func start(sender: UIButton?) {
        if CTBleHelper.blePowerdOn() != 1 {
            let alert: UIAlertController = UIAlertController.init(title: "请打开手机蓝牙", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertAction.Style.cancel, handler: nil))
            self.showAlert(alert: alert, sender: self.start)
            return
        }

        if CTBleHelper.connectStatus() == 2 {
            self.stop(sender: self.stop)
        }

        self.xf_Log(logX: "开始连接.")
        CTSwiftLinker.startBleLink()

        self.maskView.isHidden = false
        self.start.isUserInteractionEnabled = false
        self.start.isSelected = false
        self.stop.isUserInteractionEnabled = true
        self.stop.isSelected = true
    }

    @objc func stop(sender: UIButton?) {
        self.xf_Log(logX: "手动停止.")
        CTSwiftLinker.stop()
        CTBleHelper.cleanDeviceCache()
        self.resetUI()
    }

    @objc func getInfo(sender: UIButton) {
        weak var weakSelf = self

        let alert: UIAlertController = UIAlertController.init(title: "请选择要获取的信息", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction.init(title: "wifiStatus", style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.wifiStatus()
        }))
        alert.addAction(UIAlertAction.init(title: "MAC", style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.getMAC()
        }))
        alert.addAction(UIAlertAction.init(title: "Version", style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.getVersion()
        }))
        alert.addAction(UIAlertAction.init(title: "Battery", style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.getBattery()
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel,
                                           handler:nil))
        self.showAlert(alert: alert, sender: self.getInfo)
    }

    @objc func startBleUpgrade(sender: UIButton) {
        let alertTitle: String = "选择蓝牙固件版本"
        let bleVerTitles: Array = ["Release_Ble_2.0.0（归一化）", "Release_Ble_2.1.0（支持有线）"]
        let bleVersions: Array = ["BLE_2.0.0_20000", "BLE_2.1.0_20100"]

        weak var weakSelf = self
        let bleAlert: UIAlertController = UIAlertController.init(title: alertTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for i in 0..<bleVerTitles.count {
            let title: String = bleVerTitles[i]
            let version: String = bleVersions[i]
            bleAlert.addAction(UIAlertAction.init(title: title, style: UIAlertAction.Style.default,
                                                  handler: { (action: UIAlertAction) in
                                                    weakSelf?.xf_Log(logX: NSString.init(format: "当前选择版本：%@", title))
                                                    weakSelf?.startUpdateBle(verName: version as NSString)
            }))
        }
        bleAlert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        self.showAlert(alert: bleAlert, sender: self.startBleUpgrade)
    }

    @objc func startCamera(sender: UIButton) {
        self.xf_Log(logX: NSString.init(format: "开始启动摄像头[ip：%@]...", CTSwiftLinker.shared().ip))

        weak var weakSelf = self

        //let cameraCtr: CameraHelperViewController = CameraHelperViewController()
        let cameraCtr: EasyCameraViewController = EasyCameraViewController()
        cameraCtr.ip = CTSwiftLinker.shared().ip
        cameraCtr.handler_log = { (log: NSString) in
            weakSelf?.xf_Log(logX: log)
        }

        self.shouldReset = false
        self.navigationController?.present(cameraCtr, animated: true, completion: nil)
    }

    @objc func startCoreUpgrade(sender: UIButton) {
        let alertTitle: String = "选择核心固件版本"
        let kernelVerTitles: Array = ["Release_Core_3.0.0（归一化）", "Release_Core_3.1.0（有线支持）"]
        let kernelVersions: Array = ["Core_3.0.0_30000", "Core_3.1.0_30100"]

        weak var weakSelf = self
        let coreAlert: UIAlertController = UIAlertController.init(title: alertTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for i in 0..<kernelVerTitles.count {
            let title: String = kernelVerTitles[i]
            let version: String = kernelVersions[i]
            coreAlert.addAction(UIAlertAction.init(title: title, style: UIAlertAction.Style.default,
                                                   handler: { (action: UIAlertAction) in
                                                    weakSelf?.xf_Log(logX: NSString.init(format: "当前选择版本：%@", title))
                                                    weakSelf?.startUpdateCore(verName: version as NSString)
            }))
        }
        coreAlert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        self.showAlert(alert: coreAlert, sender: self.startCoreUpgrade)
    }

    @objc func calibrationTools(sender: UIButton) {
        weak var weakSelf = self

        let alert: UIAlertController = UIAlertController.init(title: "请选择 校准 选项", message: nil,
                                                              preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction.init(title: "calibration（校准）",
                                           style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.calibrationAction()
        }))
        alert.addAction(UIAlertAction.init(title: "recalibration（回滚）",
                                           style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.recalibration()
        }))
        alert.addAction(UIAlertAction.init(title: "restartNVDS（恢复配置）",
                                           style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.restartNVDS()
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel,
                                           handler:nil))
        self.showAlert(alert: alert, sender: self.calibration)
    }

    @objc func wiredMode(sender: UIButton) {
        let bleVersion: Int = (CTBleHelper.deviceInfoCache()!["BleVersion"] as! NSNumber).intValue
        let coreVersion: Int = (CTBleHelper.deviceInfoCache()!["CoreVersion"] as! NSNumber).intValue

        if bleVersion < 20100 || coreVersion < 30100 {
            self.xf_Log(logX: "固件版本不符合要求，已取消.")
            return
        }

        weak var weakSelf = self

        let alert: UIAlertController = UIAlertController.init(title: "请选择设备模式", message: nil,
                                                              preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction.init(title: "混合 模式",
                                           style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.setWiredMode(mode: 1)
        }))
        alert.addAction(UIAlertAction.init(title: "[仅]无线 模式",
                                           style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.setWiredMode(mode: 2)
        }))
        alert.addAction(UIAlertAction.init(title: "[仅]有线 模式",
                                           style: UIAlertAction.Style.default,
                                           handler: { (action: UIAlertAction) in
                                            weakSelf?.setWiredMode(mode: 3)
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel,
                                           handler:nil))
        self.showAlert(alert: alert, sender: self.setWiredMode)
    }

    @objc func shutdown(sender: UIButton) {
        CTBleHelper.shutdown(nil)
        if !sender.isEqual(self.shutdown) {
            self.xf_Log(logX: "设备已自动关机.")
        }
    }
}
