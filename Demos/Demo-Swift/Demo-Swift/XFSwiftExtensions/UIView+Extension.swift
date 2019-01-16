//
//  UIView+Extension.swift
//  Demo-Swift
//
//  Created by 胡文峰 on 2019/1/13.
//  Copyright © 2019 XIAOFUTECH. All rights reserved.
//

import Foundation

func XFWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

func XFHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

func XFScale() -> CGFloat {
    return XFUIAdaptationHelper.scale()
}

func XFSafeTop () -> CGFloat {
    return XFUIAdaptationHelper.safeTop()
}

func XFSafeBottom() -> CGFloat {
    return XFUIAdaptationHelper.safeBottom()
}

func XFNaviBarHeight() -> CGFloat {
    return XFSafeTop()+44.0
}

func XFView(bgColor: UIColor, frame: CGRect) -> UIView {
    var view: UIView = UIView()
    view = UIView.init(frame: frame)
    view.backgroundColor = bgColor
    return view
}

extension UIView {

    // .xf_X
    public var xf_X: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var rect = self.frame
            rect.origin.x = newValue
            self.frame = rect
        }
    }

    // .xf_Y
    public var xf_Y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue
            self.frame = rect
        }
    }

    // .xf_Width
    public var xf_Width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var rect = self.frame
            rect.size.width = newValue
            self.frame = rect
        }
    }

    // .xf_Height
    public var xf_Height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var rect = self.frame
            rect.size.height = newValue
            self.frame = rect
        }
    }

    // .xf_Left
    public var xf_Left: CGFloat {
        get {
            return self.xf_X
        }
    }

    // .xf_Right
    public var xf_Right: CGFloat {
        get {
            return self.xf_X + self.xf_Width
        }
    }

    // .xf_Top
    public var xf_Top: CGFloat {
        get {
            return self.xf_Y
        }
    }

    // .xf_Bottom
    public var xf_Bottom: CGFloat {
        get {
            return self.xf_Y + self.xf_Height
        }
    }

}
