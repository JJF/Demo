//
//  File.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/15.
//

import UIKit
import MapKit



public enum WaypointHeadingType: Int {
    case auto
    case usingWaypointHeading
    case towardPointOfInterest
}

public protocol WaypointMapControllerDelegate {
    

    func annotationDragBegin(_ draggingView: UIView)

    func annotationDragging(_ draggingView: UIView, _ coord: CLLocationCoordinate2D)
    
    func annotationDragEnded(_ draggingView: UIView, _ coord: CLLocationCoordinate2D)
    
}


private var mapController: WaypointMapController! = nil

public class WaypointMapController: NSObject {
 
    
    public class func instance() -> WaypointMapController {
        if mapController == nil {
            mapController = WaypointMapController()
        }
        
        return mapController
    }
//    class func setView(_ inView: UIView) {
//        inView.addSubview(self.mapView)
//        self.mapView.delegate = self
//    }
    public func initWaypoint(_ inView: UIView, _ configuration: OpenWaypointConfiguration?) {
        inView.addSubview(self.mapview)
        inView.sendSubviewToBack(self.mapview)
//        self.mapview.delegate = self
//        self.mapview.initMapController(self)
        self.mapview.delegate = mapHandler
        mapHandler.controllerDelegate = self
        
        var rc = inView.frame
        rc.origin = CGPoint(x: 0, y: 0)
        self.mapview.frame = rc
        self.mapview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    
    private lazy var mapHandler = WaypointMapHandler()
    
    var delegate: WaypointMapController? = nil
    private lazy var mapview = MKMapView()
    
    var settings = OpenWaypointSettings()
    
    var wptAnns: [WaypointAnnotation] = []
    var routeLines: [StraightPolyline] = []
    var curveLine: CurvePolyline? = nil
    var radiusInMeters: [CGFloat] = []
    var interestingAnn: InterestingAnnotation? = nil

    // Annotation Drag ----------------
    var initialPt: CGPoint! = nil
    var initialCenterPt: CGPoint! = nil
    var lastPt: CGPoint! = nil
    // Annotation Drag -----------------

    var initialCalloutCenterPt: CGPoint! = nil

    func mapView() -> MKMapView {

        return self.mapview
    }

    ////////////////////////////////////////////////-----------------------
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        let pt = sender.location(in: sender.view)
        let coord = self.mapView().convert(pt, toCoordinateFrom: nil)
        
        self.addPoint(coordinate: coord)
    }
    
    // MARK:----- Waypoint ------
    private func insertPointAt(coordinate: CLLocationCoordinate2D,atIndex: Int, _ newByButton: Bool=false, _ yawAngle: Int = 0) {
        // 设置航点或兴趣点

//        DispatchQueue.main.async {
//            if self.currentEditingMode == .wayPoint {
//                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                self.editPoints.insert(location, at: atIndex)
                let annotation = WaypointAnnotation(coord: coordinate)
                annotation.index = atIndex//self.editPoints.count - 1

            
                if newByButton {
//                    annotation.headingChanged = true
                    annotation.yawAngle = CGFloat(Double(yawAngle)/180.0 * 3.1416)
                }
                self.wptAnns.insert(annotation, at: atIndex)
                self.mapView().addAnnotation(annotation)

                // update index when insert
                var n = atIndex
                repeat{
                    self.wptAnns[n].index = n
                    (self.mapView().view(for: self.wptAnns[n]) as? WaypointAnnotationView)?.updateNumber()
                    n += 1
                }while n < self.wptAnns.count

                // Add route line

                self.updateLines(isCurved: settings.curved)

//                if let interestCoord = self.interestingAnn?.coordinate {
//                    CommonUtility.mainOperationVC()?.updateFlihgtpontHeading(annIndex: atIndex, toCoordinate: interestCoord)
//                }
//            }

//        }
        
    }
    func addPoint(coordinate: CLLocationCoordinate2D, _ newByButton: Bool=false, _ yawAngle: Int = 0) -> Void {
        self.insertPointAt(coordinate: coordinate, atIndex: self.wptAnns.count, newByButton, yawAngle)
    }
    
    
    func insertFirstPoint() -> CLLocationCoordinate2D? {
        // if it is first one, calculate & insert new one, then call the same code
        //        var index = atIndex
        //        if index == 0 {
        //
        //            index += 1
        //        }
        if wptAnns.count < 2 {
            return nil
        }

        let pt1 = mapView().convert(self.wptAnns[0].coordinate, toPointTo: mapView())
        let pt2  = mapView().convert(self.wptAnns[1].coordinate, toPointTo: mapView())
            
        var pt0 = pt1
        pt0.x = pt1.x + (pt1.x - pt2.x)
        pt0.y = pt1.y + (pt1.y - pt2.y)
        
        let coord = mapView().convert(pt0, toCoordinateFrom: mapView())
//        self.delegate?.map_wptWillInsert(coord, 0)
        self.insertPointAt(coordinate: coord, atIndex: 0)

        return coord
        
    }

    func insertPoint(_ atIndex: Int) -> CLLocationCoordinate2D? {
        // if it is first one, calculate & insert new one, then call the same code
//        var index = atIndex
//        if index == 0 {
//
//            index += 1
//        }
        if atIndex > 0 {
            let previousPt = mapView().convert(self.wptAnns[atIndex-1].coordinate, toPointTo: mapView())
            let currentPt = mapView().convert(self.wptAnns[atIndex].coordinate, toPointTo: mapView())

            var newPt = previousPt
            newPt.x = (previousPt.x + currentPt.x)/2
            newPt.y = (previousPt.y + currentPt.y)/2

            let coord = mapView().convert(newPt, toCoordinateFrom: mapView())
//            self.delegate?.map_wptWillInsert(coord, atIndex)
            self.insertPointAt(coordinate: coord, atIndex: atIndex)
            return coord
        }

        return nil
    }
    func removePoint(atIndex: Int){

        if self.radiusInMeters.count > atIndex {
            self.radiusInMeters.remove(at: atIndex)
        }

//        let ann = self.wptAnns[atIndex]

        mapView().removeAnnotations(self.wptAnns)
        self.wptAnns.remove(at: atIndex) // just remove one

        if atIndex < self.wptAnns.count {
            var n = atIndex
            while(n < self.wptAnns.count){
                self.wptAnns[n].index -= 1
                n += 1
            }
        }

        mapView().setNeedsDisplay()
//        mapView?.setNeedsLayout()
        mapView().addAnnotations(self.wptAnns)

        updateLines(isCurved: settings.curved)
        
    }

    
//    func initWptsHeadingChanged() {
//        for wpt in self.wptAnns {
////            wpt.headingChanged = false
//        }
//    }
//
//    func headingMoved(_ index: Int) {
//        if let wptAnn = self.wptAnns[index] as? WaypointAnnotation {
////            wptAnn.headingChanged = true
//        }
//    }
    
    func updateLines(isCurved: Bool){
        let count = self.wptAnns.count
        
        if count > 1 {
            
            let aWayPoints = self.wptAnns
            let coordinateArray = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: aWayPoints.count)
            var n = 0
            for wp in aWayPoints{
                coordinateArray[n] = wp.coordinate
                n += 1
            }
            
            let pLine = StraightPolyline(coordinates: coordinateArray, count: count)
            pLine.updateColorByMap()
            mapView().removeOverlays(self.routeLines)
            mapView().addOverlay(pLine)
            self.routeLines.append(pLine)
            
            if isCurved {
                if let pCurve = self.curveLine {
                    mapView().removeOverlay(pCurve)
                }
                let pLine2 = CurvePolyline(coordinates: coordinateArray, count: count)
                mapView().addOverlay(pLine2)
                self.curveLine = pLine2
            }
            
        }else{
            mapView().removeOverlays(self.routeLines)
            self.routeLines.removeAll()
            
            if let pCurve = self.curveLine {
                mapView().removeOverlay(pCurve)
                self.curveLine = nil
            }
        }
    }

    // MARK: ------- Interest point --------
    func addInterestPoint(coordinate: CLLocationCoordinate2D){
//        if self.currentEditingMode != .interestingPoint {
//            return
//        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let ann = self.interestingAnn {
            ann.coordinate = location.coordinate
        }else{
            let annotation = InterestingAnnotation(coord: location.coordinate)
//            if let ann = self.interestingAnn {
//                mapView().removeAnnotation(ann)
//            }
            self.interestingAnn = annotation
            mapView().addAnnotation(annotation)
        }
    }

    func updateInterestAnn(_ enableStatus: Bool) {
        if let ann = self.interestingAnn {
            (mapView().view(for: ann) as? InterestingAnnotationView)?.updateInterestAnn(enableStatus)
        
            if !enableStatus {
                (mapView().view(for: ann) as? InterestingAnnotationView)?.updateAltitude(nil)

            }
        }
    }

    func updateInterestAnnAltitude(_ fAltitude: Float?) {
        if let ann = self.interestingAnn {
            (mapView().view(for: ann) as? InterestingAnnotationView)?.updateAltitude(fAltitude)
        }
    }
    func removeInterestAnn() -> Bool {

        if let ann = self.interestingAnn {
            mapView().removeAnnotation(ann)
            self.interestingAnn = nil
            return true
        }
        return false
    }
    
    public func removeAll() {
        mapView().removeAnnotations(self.wptAnns)
        self.wptAnns.removeAll()
        if let ann = self.interestingAnn {
            mapview.removeAnnotation(ann)
            self.interestingAnn = nil
        }
        
        if self.routeLines.count > 0 {
            mapView().removeOverlays(self.routeLines)
            self.routeLines.removeAll()
        }
        if let pCurve = self.curveLine {
            mapView().removeOverlay(pCurve)
            self.curveLine = nil
        }
    }

}

extension WaypointMapController {
    
    func convert(coord: CLLocationCoordinate2D) -> CGPoint {
        return mapView().convert(coord, toPointTo: mapView())
    }
    
    func convert(pt: CGPoint) -> CLLocationCoordinate2D {
        return mapView().convert(pt, toCoordinateFrom: mapView())
    }

}

// Drag
extension WaypointMapController {
    @objc func dragWaypointAnnotation(_ longGesture: UILongPressGestureRecognizer) {

        if !(settings.draggable) {
            return
        }
        
        guard let draggingView = longGesture.view else {
            return
        }


        let pt = longGesture.location(in: self.mapView())
        var coord = kCLLocationCoordinate2DInvalid
        if self.initialPt != nil {
            let newPt = CGPoint(x: initialCenterPt.x + pt.x - initialPt.x, y: initialCenterPt.y + pt.y - initialPt.y - self.dragging_offset_Y()) // because centerOff
            coord = self.convert(pt: newPt)
        }

        switch longGesture.state {
        case .began:
            
            print("Drag begin!!!")
            
            self.initialPt = pt
            self.initialCenterPt = longGesture.view?.center
            self.lastPt = pt
            
            self.annotationDragBegin(draggingView)
            
            break
        case .changed:
            
            if abs(self.lastPt.x - pt.x) > 50 || abs(self.lastPt.y - pt.y) > 50 {
                print("abnormal")
            }else {
                draggingView.center = CGPoint(x: self.initialCenterPt.x + pt.x-self.initialPt.x, y: self.initialCenterPt.y + pt.y-self.initialPt.y)
                self.annotationDragging(draggingView, coord)
            }

            self.lastPt = pt
//            print("State: " + "\(longGesture.state.rawValue)" + "  x: " + "\(pt.x)" + "y: " + "\(pt.y)")

            break
            
        case .ended:

            self.annotationDragEnded(draggingView, coord)

            self.initialPt = nil
            self.initialCenterPt = nil
            self.lastPt = nil

            break
    
        default:
            print("Ignore...")
        }
            
    }

    @objc func annotationDragBegin(_ draggingView: UIView) {
        draggingView.startDragging()

        self.delegate?.annotationDragBegin(draggingView)
    }
    @objc func annotationDragging(_ draggingView: UIView, _ coord: CLLocationCoordinate2D) {
        if let annView = draggingView as? MKAnnotationView {
            (annView.annotation as? WaypointAnnotation)?.coordinate = coord
            (annView.annotation as? InterestingAnnotation)?.coordinate = coord
        }
//        self.updateLines(isCurved: settings.curved)
//        fatalError("Only called by child re-implement")
        self.delegate?.annotationDragging(draggingView, coord)
    }
    @objc func annotationDragEnded(_ draggingView: UIView, _ coord: CLLocationCoordinate2D) {
//        fatalError("Only called by child re-implement")

        if let annView = draggingView as? MKAnnotationView {
            (annView.annotation as? WaypointAnnotation)?.coordinate = coord
            (annView.annotation as? InterestingAnnotation)?.coordinate = coord
        }

        draggingView.endDragging()
        self.updateLines(isCurved: settings.curved)

        
        self.delegate?.annotationDragEnded(draggingView, coord)
    }

    @objc func dragging_offset_Y() -> CGFloat {
        return -25
    }

}
