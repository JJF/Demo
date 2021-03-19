//
//  LocationUtil.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/17.
//

import Foundation
import MapKit


class LocationUtil: NSObject {
    class func calculateCurvePoints(_ pt_prev: CGPoint,_ pt: CGPoint,_ pt_next: CGPoint,_ radius: CGFloat) ->(CGPoint, CGPoint) {
        let contr1 = LocationUtil.calPointInLine(pt1: pt, pt2: pt_prev, deltaLengthFromPt1: radius)
        let contr2 = LocationUtil.calPointInLine(pt1: pt, pt2: pt_next, deltaLengthFromPt1: radius)
        
        return (contr1, contr2)
    }

    class func calPointInLine(pt1: CGPoint, pt2: CGPoint,deltaLengthFromPt1: CGFloat) -> CGPoint {
        var newPt: CGPoint = pt1
        if abs(pt2.x - pt1.x) > 0.01 {
            let kRate = (pt1.y - pt2.y) / (pt1.x - pt2.x)
            if pt2.x > pt1.x {
                newPt.x = pt1.x + deltaLengthFromPt1/(sqrt(1 + kRate*kRate))
            }else{
                newPt.x = pt1.x - deltaLengthFromPt1/(sqrt(1 + kRate*kRate))
            }
            
            newPt.y = pt1.y - kRate*(pt1.x - newPt.x)
        }else{
            if pt2.y > pt1.y {
                newPt.y = pt1.y + deltaLengthFromPt1
            }else{
                newPt.y = pt1.y - deltaLengthFromPt1
            }
        }
        return newPt
    }
    
    
    
    class func RADIAN(angle: Float) -> Float {
        return Float(Double(angle) * Double.pi / 180.0)
    }
    class func distanceBetween(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Double {
        let lat1 = Float(coord1.latitude)
        let lng1 = Float(coord1.longitude)
        let lat2 = Float(coord2.latitude)
        let lng2 = Float(coord2.longitude)

        let deltaLat = LocationUtil.RADIAN(angle: lat1) - LocationUtil.RADIAN(angle: lat2)
        let deltaLng = LocationUtil.RADIAN(angle: lng1) - LocationUtil.RADIAN(angle: lng2)
        return Double(6378137 * 2 * asin(sqrt(pow(sin(deltaLat/2)  ,2) + cos(lat1) * cos(lat2) * pow(deltaLng/2, 2)  )))
    }

}
