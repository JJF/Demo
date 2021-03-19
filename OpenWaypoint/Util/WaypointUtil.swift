//
//  WaypointUtil.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/16.
//

import UIKit


class WaypointUtil: NSObject {
    
    class func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    class func getBundle() -> Bundle? {

        return Bundle(path: (Bundle.main.bundlePath as NSString).appendingPathComponent( "OpenWaypoint.bundle"))
    }
    
    class func isChineseLanguage() -> Bool {
        return WaypointUtil.localizedString("language") == "cn"
    }

//    class func getXCAssetPath() -> String? {
//        return CommonUtil.getBundle()?.bundlePath + ""
//    }
    class func localizedString(_ keyStr: String) -> String {
        return WaypointUtil.getBundle()?.localizedString(forKey: keyStr, value: nil, table: nil) ?? keyStr
    }

    class func loadImage(_ imgName: String) -> UIImage? {

        
        let img = UIImage(named: imgName, in: WaypointUtil.getBundle(), compatibleWith: nil)

        return img
    }



}
