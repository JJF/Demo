//
//  InterestingAnnotationView.swift
//  OpenWaypoint
//
//  Created by Jeff on 2018/4/9.
////

import MapKit

class InterestingAnnotation: MKPointAnnotation {
    
    //    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    //    var title: String? {return "title"}
    //    var subtitle: String? { return "subtitle"}
    var yawAngle: CGFloat = 0.0
    
    //
    init(coord: CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coord
    }
    //
    //    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
    //        self.coordinate = newCoordinate
    //    }
    
//    func updateHeading(heading: CGFloat) {
//        self.annotationView?.updateHeading(heading: heading)
//    }
}


class InterestingAnnotationView: MKAnnotationView {
    var altitudeView: UIButton? = nil
    var dragGesture: UILongPressGestureRecognizer? = nil

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        //            self.isEnabled = false
//        self.isDraggable = true
        self.image = UIImage(named: "interestAnn")
        self.centerOffset = CGPoint(x: 0, y: kWaypointAnnotationCenterOff_Y)
    }
    func updateInterestAnn(_ bStatus: Bool) {
        if bStatus {
        self.image = UIImage(named: "interestAnn")
        }else {
            self.image = UIImage(named: "interestAnn_disable")
        }
    }
    func updateAltitude(_ fAltitude: Float?) {
        if let fA = fAltitude {
            if altitudeView == nil {
                let width = self.frame.size.width
                altitudeView = UIButton(frame: CGRect(x: (self.frame.size.width-width)/2, y: width * -0.8, width: width, height: width))
                self.addSubview(altitudeView!)
                self.clipsToBounds = false
                altitudeView?.setBackgroundImage(UIImage(named: "ann_altitude_bg"), for: .normal)
            }
            altitudeView?.isHidden = false
//            altitudeView?.setTitle(, for: .normal)
            let text = "\(Int(fA))"
            var fontSize: CGFloat = 17
            let attrText = NSMutableAttributedString(string: text)
            if text.count >= 2{
                fontSize = 15
            }
            attrText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], range: NSRange(location: 0, length: text.count))
            attrText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], range: NSRange(location: 0, length: text.count))
            altitudeView?.setAttributedTitle(attrText, for: .normal)
        }else{
            altitudeView?.removeFromSuperview()
            altitudeView = nil
//            altitudeView?.isHidden = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setDragState(_ newDragState: MKAnnotationView.DragState, animated: Bool) {
        super.setDragState(newDragState, animated: animated)
    }

}
