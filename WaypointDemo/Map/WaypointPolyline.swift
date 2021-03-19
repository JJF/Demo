//
//  MyPolyline.swift
//  OpenWaypoint
//
//  Created by Jeff on 2020/6/8.
//

import UIKit
import MapKit

class StraightPolyline: MKPolyline {
    var color = UIColor.clear
    func updateColorByMap() {
        self.color = StraightPolyline.wptLineColor() //UIColor(red: 0.4, green: 0.0, blue: 0.783, alpha: 1.0)
    }
    func updateColorByAircraft() {
        self.color = UIColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0)
    }

    class func wptLineColor() -> UIColor {
        return UIColor(red: 0.4, green: 0.0, blue: 0.783, alpha: 1.0)
//        return UIColor(red: 0.5, green: 0.5, blue: 0.9, alpha: 0.4)
}
}

class CurvePolyline: MKPolyline {
//    let color = UIColor(red: 200.0/255, green: 96.0/255, blue: 60.0/255, alpha: 0.0)
    let color = UIColor.clear
}

//class HomelocationPolyline: MKPolyline {
//
//    class func homeColor() -> UIColor {
//        return UIColor(red: 0.45, green: 0.9, blue: 0.36, alpha: 1.0)
//    }
//}

class CurvePathRenderer: MKPolylineRenderer {
    var ptsInView : [CGPoint]? = nil
    var radiusOfPts: [CGFloat]? = nil
    var lengthsOfPts: [Double]? = nil
    
    
    class func curveColor() -> UIColor {
        return UIColor(red: 190.0/255, green: 102.0/255, blue: 72.0/255, alpha: 1.0)
    }

    override func createPath() {
        
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)

        
        let mapCGRect = rect(for: overlay.boundingMapRect)

        let calMax = {() -> (CGFloat,CGFloat,CGFloat,CGFloat) in
            if let pts = self.ptsInView, pts.count > 2 {
                var minX = pts[0].x
                var maxX = pts[0].x
                var minY = pts[0].y
                var maxY = pts[0].y
                for pt in pts{
                    if pt.x < minX {
                        minX = pt.x
                    }
                    if pt.x > maxX{
                        maxX = pt.x
                    }
                    if pt.y < minY {
                        minY = pt.y
                    }
                    if pt.y > maxY{
                        maxY = pt.y
                    }
                }
                return (minX,maxX,minY,maxY)
            }
            return (0.0,0.0,0.0,0.0)
        }
        // points in map view ==> points for mapRect
        let mappingPts = {() -> [CGPoint]? in
            let (minX,maxX,minY,maxY) = calMax()

            if let pts = self.ptsInView, pts.count > 2 {
                var ptsForMaprect : [CGPoint] = []
                for originalPt in pts{
                    ptsForMaprect.append(CGPoint(x: mapCGRect.origin.x + (originalPt.x - minX) * mapCGRect.size.width / (maxX - minX), y: mapCGRect.origin.y + (originalPt.y - minY) * mapCGRect.size.height / (maxY - minY)))
                }
                
                return ptsForMaprect
            }

            return nil
        }
        
        let ptsForMaprect = mappingPts()
        
        let aPath = UIBezierPath()
        aPath.lineWidth = 1.0

        aPath.lineCapStyle = .round //线条拐角
        aPath.lineJoinStyle = .round //终点处理

        
        // Set the starting point of the shape.

        if let pts = ptsForMaprect , let rPts = radiusOfPts, let lengths = lengthsOfPts{
            aPath.move(to: pts[0])
            var n = 1
            while n < pts.count - 1{

                let length1 = sqrt((pts[n-1].x - pts[n].x)*(pts[n-1].x - pts[n].x) + (pts[n-1].y - pts[n].y)*(pts[n-1].y - pts[n].y))
//                let length2 = sqrt((pts[n].x - pts[n+1].x)*(pts[n].x - pts[n+1].x) + (pts[n+1].y - pts[n].y)*(pts[n+1].y - pts[n].y))
                

                let currentRadius1  = rPts[n] * CGFloat(Double(length1) / lengths[n-1])
                
                let (contr1, contr2) = LocationUtil.calculateCurvePoints(pts[n-1], pts[n], pts[n+1], currentRadius1)
                
                aPath.addLine(to: contr1)

                aPath.move(to: contr1)
                aPath.addCurve(to: contr2, controlPoint1: contr1, controlPoint2: pts[n] )
                aPath.move(to: contr2)
                n += 1
            }
            aPath.addLine(to: pts[pts.count - 1])
            aPath.move(to: pts[pts.count - 1])
        }
        aPath.close()

        if self.overlay is CurvePolyline {
            context.setStrokeColor( CurvePathRenderer.curveColor().cgColor)

        }else{
            context.setStrokeColor(UIColor.yellow.cgColor)
        }
        self.strokePath(aPath.cgPath, in: context)
        
    }
}

