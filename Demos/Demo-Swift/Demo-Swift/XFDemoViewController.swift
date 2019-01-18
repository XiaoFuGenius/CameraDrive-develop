//
//  XFDemoViewController.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/12.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import UIKit

class XFDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "XF Sdk Demo"
        self.view.backgroundColor = UIColor.XF_f6Gray

        self.setupFuncs();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }

    func setupFuncs() {
        var frame: CGRect = CGRect.init(x: 0, y: 0, width: 50, height: 30)
        let settingBtn: UIButton = UIButton.init(frame: frame)
        settingBtn.setTitle("设置", for: UIControl.State.normal)
        settingBtn.titleLabel?.font = XFFont(fontSize: 17.0)
        settingBtn.setTitleColor(XFColor(rgbValue: 0x333333, alpha: 1.0), for: UIControl.State.normal)
        settingBtn.addTarget(self, action: #selector(openApplicationSettings(sender:)), for: UIControl.Event.touchUpInside)
        let item = UIBarButtonItem.init(customView: settingBtn)
        self.navigationItem.rightBarButtonItems = [item]

        // ------------------------------------------------------------------------------------------

        let width: CGFloat = XFWidth()/3
        let height: CGFloat = 56.0

        frame = CGRect.init(x: width/3, y: 15, width: width, height: height)
        let cameraDrive: UIButton = self.setupButtonTitle(title: "CTBleHelper",
                                                          action: #selector(showCameraDrive), frame: frame)
        self.view.addSubview(cameraDrive)

        frame = CGRect.init(x: cameraDrive.xf_GetRight() + width/3, y: cameraDrive.xf_GetTop(),
                            width: width, height: height)
        let easyLinker: UIButton = self.setupButtonTitle(title: "CTEasyLinker\n（推荐）",
                                                         action: #selector(showEasyLinker),
                                                         frame: frame)
        self.view.addSubview(easyLinker)

        frame = CGRect.init(x: cameraDrive.xf_GetRight() + width/3,
                            y: cameraDrive.xf_GetBottom() + width/3,
                            width: width, height: height)
        let swiftLinker: UIButton = self.setupButtonTitle(title: "CTSwiftLinker\n（推荐+）",
                                                          action: #selector(showSwiftLinker),
                                                          frame: frame)
        self.view.addSubview(swiftLinker)
    }

    @objc func openApplicationSettings(sender: UIButton) {
        XF_ApplicationOpenSettings(type: 0)
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

    @objc func showCameraDrive() {
        let ctr: UIViewController = BleHelperViewController()
        self.navigationController?.pushViewController(ctr, animated: true)
    }

    @objc func showEasyLinker() {
        let ctr: UIViewController = EasyLinkerViewController()
        self.navigationController?.pushViewController(ctr, animated: true)
    }

    @objc func showSwiftLinker() {
        //let nameSpace: NSString = Bundle.main.infoDictionary!["CFBundleExecutable"] as! NSString
        //let className = (nameSpace as String) + "." + "SwiftLinkerViewController"
        //let Clz = NSClassFromString(className) as! UIViewController.Type
        //let ctr: UIViewController = Clz.init()

        let ctr: UIViewController = SwiftLinkerViewController()
        self.navigationController?.pushViewController(ctr, animated: true)
    }

}
