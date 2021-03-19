//
//  WaypointMapController+Map.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/16.
//

import UIKit
import MapKit


extension WaypointMapController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /*if(annotation is HomeAnnotation) {
            let annoView = HomeAnnotationView(annotation: annotation, reuseIdentifier:"Home_Annotation")
            annoView.annotation = annotation
            return annoView
        }else if(annotation is DJIAircraftAnnotation) {
            let annoView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier:"Aircraft_Annotation")
            
            
            //            mapController.aircraftAnnView = annoView
            return annoView
        }else */if(annotation is InterestingAnnotation) {
//            let annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "Interesting_Annotation", for: annotation)
//            if annoView == nil {
    
                let annView = InterestingAnnotationView(annotation: annotation, reuseIdentifier:  nil)//"Interesting_Annotation")
            
                if annView.dragGesture == nil {

                    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragWaypointAnnotation))
                    annView.addGestureRecognizer(longGesture)
                    annView.dragGesture = longGesture
                    annView.isEnabled = false
                }
//                annoView.annotation = annotation
//            }
            return annView
        }else if (annotation is WaypointAnnotation) {

            var wptView: WaypointAnnotationView? = nil
                
            wptView = WaypointAnnotationView(annotation:annotation, reuseIdentifier: nil) //WaypointAnnotationView.annIdentifier())
            
            if wptView?.dragGesture == nil {
                let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragWaypointAnnotation))
                wptView?.addGestureRecognizer(longGesture)
                wptView?.dragGesture = longGesture
                wptView?.isEnabled = false
            }
            
            
            // update heading
            
//            self.updateCurrentHeading(wptView, mapView)

            return wptView
        }else if (annotation is MKUserLocation){
            return nil
        }else{


//            if let v = self.calledDe
            
            let view = EmptyAnnotationView(annotation:annotation, reuseIdentifier: "Emptypoint_Annotation")
            view.isSelected = false
            return view
        }
    }
    
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is StraightPolyline {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = (overlay as! StraightPolyline).color
            polylineRenderer.lineWidth = 3.0
            
            polylineRenderer.lineCap = .butt
            polylineRenderer.lineJoin = .bevel
            
            return polylineRenderer
        }else if overlay is CurvePolyline {
            let polylineRenderer = CurvePathRenderer(overlay: overlay)
            // get points in map view
            
            let (pts, cornersOfPts, lengths) = self.initForCurveline()

            polylineRenderer.ptsInView = pts
            polylineRenderer.radiusOfPts = cornersOfPts
            polylineRenderer.lengthsOfPts = lengths
            self.radiusInMeters = cornersOfPts
            
            
            polylineRenderer.strokeColor = (overlay as! CurvePolyline).color
            polylineRenderer.lineWidth = 1.5
            return polylineRenderer
        }/*else if overlay is HomelocationPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor =  HomelocationPolyline.homeColor()
            polylineRenderer.lineWidth = 1.5
            return polylineRenderer
        }*/
        
        print("Error!not expedted renderer!")
        return MKOverlayRenderer()
        
    }

}

extension WaypointMapController {
    func initForCurveline() -> ([CGPoint], [CGFloat], [Double]) {
        let wpts = self.wptAnns
        var pts: [ CGPoint] = []
        var cornersOfPts: [CGFloat] = []
        var lengths: [Double] = []
        var n = 0
        while n < wpts.count {
            let pt = self.convert(coord: wpts[n].coordinate)
            pts.append(pt)
            if n == 0 {
                cornersOfPts.append(0.2)
            }else if n >= wpts.count - 1 {
                let length1 = LocationUtil.distanceBetween(coord1: wpts[n-1].coordinate, coord2: wpts[n].coordinate)
                lengths.append(length1)
                
                cornersOfPts.append(0.2)
            }else{
                let length1 = LocationUtil.distanceBetween(coord1: wpts[n-1].coordinate, coord2: wpts[n].coordinate)
                let length2 = LocationUtil.distanceBetween(coord1: wpts[n].coordinate, coord2: wpts[n+1].coordinate)
                
                lengths.append(length1)
                
                var maxRadius = sqrt(fmin(length1, length2))
                var maxRadiusToDisplay = fmin(length1, length2)/3
                if maxRadius > maxRadiusToDisplay {
                    maxRadius = maxRadiusToDisplay
                }else if maxRadius < 0.2 {
                    maxRadius = 0.2
                }
                
                
                
//                if maxRadiusToDisplay > maxRadius {
//                    maxRadiusToDisplay = maxRadius
//                }
                
                // mapping: radius ==> radius to display
                if maxRadiusToDisplay > 1000 {
                    maxRadiusToDisplay = 1000
                }
                
                cornersOfPts.append(CGFloat(maxRadiusToDisplay))
            }
            
            n += 1
        }

        return (pts, cornersOfPts, lengths)
    }

}

// MARK: ------- Heading -------
extension WaypointMapController {
    public func initAnns(_ forType: WaypointHeadingType) {
        
        // update interest ann status
        self.updateInterestAnn(forType == .towardPointOfInterest)

        // update heading hidden status
        if forType == .auto
            || forType == .usingWaypointHeading
            || forType == .towardPointOfInterest {
        
            self.showWaypointHeading( true)
        }else{
            self.showWaypointHeading( false)
        }
        
        
        let fpCount = self.wptAnns.count
        if forType == .auto || forType == .usingWaypointHeading{

            DispatchQueue.main.async {

                // iterate each flight point
                for ann in self.mapView().annotations {
                    if let fpAnn = ann as? WaypointAnnotation {
                        if fpAnn.index == 0 {

                                var fAngle: CGFloat = 0
                                if self.wptAnns.count > 1 {
                                    fAngle = self.calculateAngle(fpAnn.index)
                                }

                                if let fpView = self.mapView().view(for: fpAnn) as? WaypointAnnotationView {
                                        fpView.updateHeading(angle: fAngle)
                                }

                        }else if fpAnn.index < (fpCount - 1) {
                            self.updateWaypointHeading(annIndex: fpAnn.index)
                        }else if fpAnn.index == (fpCount - 1) {

                            if let fpView = self.mapView().view(for: fpAnn) as? WaypointAnnotationView {
                                    fpView.updateHeading(angle: self.calculateAngle(fpAnn.index - 1))
                                }
                        
                        }
                    }

                }

//                self.delegate?.map_wptHeadingChanged()
            }
        }else if forType == .towardPointOfInterest {

            if let coordinate = self.interestingAnn?.coordinate{
                var n = 0
                while n < fpCount {
                    self.updateWaypointHeading(annIndex: n,toCoordinate: coordinate)
                    n += 1
                }
            }

        }/*else if forType == .usingWaypointHeading {
            for ann in mapView.annotations {
                if let fpAnn = ann as? WaypointAnnotation {

                    // heading reset
                    let fpView = mapView.view(for: fpAnn) as? WaypointAnnotationView
                    fpView?.updateHeading(angle: fpAnn.yawAngle * 3.1416 / 180.0, checkChanged: true)
                    
                }
            }

        }*/else{
//            for fpAnn in mapView.annotations {
//                if fpAnn is FlightpointAnnotation {
//                    if let fpView = mapView.view(for: fpAnn) as? FlightpointAnnotationView {
//                        fpView.headingIV.isHidden = true
//                    }
//                }
//            }
            // hide heading image
        }
        
        
    }

    func showWaypointHeading(_ willShow: Bool) {
        for ann in self.mapView().annotations {
            if ann is WaypointAnnotation {
                (self.mapView().view(for: ann) as? WaypointAnnotationView)?.headingIV.isHidden = !willShow
            }
        }
    }

    func updateWaypointHeading(annIndex: Int) {
        //        let aWPts = mapController.wayPoints()
        //        if aWPts.count > 1 {
        //            if annIndex >= 0 && annIndex < (aWPts.count - 1){
        //                let pt1 = mapView.convert(aWPts[annIndex].coordinate, toPointTo: mapView.view())
        //                let pt2 = mapView.convert(aWPts[annIndex + 1].coordinate, toPointTo: mapView.view())
        //
        //                if (pt1.y != pt2.y) {
        //                    var angle = -atan((pt2.x - pt1.x)/(pt2.y - pt1.y))
        //                    if (pt2.y > pt1.y) {
        //                        angle += 3.1416
        //                    }

        DispatchQueue.main.async {
            if let wptView = self.mapView().view(for: self.wptAnns[annIndex]) as? WaypointAnnotationView {
                wptView.updateHeading(angle: CGFloat(self.calculateAngle(annIndex)))
            }

        }

        //                }
        //            } // let aWPTs
        //        }

    }// func
    
    func updateWaypointHeading(annIndex: Int, newHeading: Int) {
        let fpAnn = self.wptAnns[annIndex]
        let fpView = mapView().view(for: fpAnn) as? WaypointAnnotationView
        fpView?.updateHeading(angle: CGFloat(Float(newHeading) / 180.0 * 3.1416))
    }

    func updateWaypointHeading(annIndex: Int,toCoordinate: CLLocationCoordinate2D) {
        let wpts = self.wptAnns

        if wpts.count > 0 {
            if annIndex >= 0 && annIndex < wpts.count{
                let pt1 = mapView().convert(wpts[annIndex].coordinate, toPointTo: mapView())
                let pt2 = mapView().convert(toCoordinate, toPointTo: mapView())
                
                if (pt1.y != pt2.y) {
                    var angle = -atan((pt2.x - pt1.x)/(pt2.y - pt1.y))
                    if (pt2.y > pt1.y) {
                        angle += CGFloat(Double.pi)
                    }
                    
                    DispatchQueue.main.async {
                        if let wptView = self.mapView().view(for: self.wptAnns[annIndex]) as? WaypointAnnotationView {
                            wptView.updateHeading(angle: CGFloat(angle))
                        }
                        
                    }
                    
                }
            } // let aWPTs
        }
        
    }// func

    
    func waypointHasSavedHeding(_ index: Int) -> Bool {
//        if let savedHeading = self.delegate?.map_wptHasChangedHeading(index) {
//            return savedHeading
//        }
        return false
    }
    
    func calculateAngle(_ annIndex: Int) -> CGFloat {
        let wpts = self.wptAnns
        if wpts.count > 1 {
            if annIndex >= 0 && annIndex <= (wpts.count - 1){
                var calculatingIndex = annIndex
                if annIndex == wpts.count-1 {
                    calculatingIndex = annIndex-1
                }
                let pt1 = mapView().convert(wpts[calculatingIndex].coordinate, toPointTo: mapView())
                let pt2 = mapView().convert(wpts[calculatingIndex + 1].coordinate, toPointTo: mapView())
                
                if (pt1.y != pt2.y) {
                    var angle = -atan((pt2.x - pt1.x)/(pt2.y - pt1.y))
                    if (pt2.y > pt1.y) {
                        angle += 3.1416
                    }
                    
                    return angle
                }
            }
        }
        
        return 0
    }

}
