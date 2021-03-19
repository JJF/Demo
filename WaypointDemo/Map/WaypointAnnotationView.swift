//
//  WaypointAnnotationView.swift
//  OpenWaypoint
//
//  Created by Jeff on 2018/4/9.
////

import UIKit
import MapKit

let kWaypointAnnotationCenterOff_Y: CGFloat = -25

protocol WaypointAnnotationData {
    func wpt_index() -> Int
    func wpt_yawAngle() -> CGFloat?
}

class WaypointAnnotation: MKPointAnnotation {

    //    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    //    var title: String? {return "title"}
    //    var subtitle: String? { return "subtitle"}
    var yawAngle: CGFloat? = 0.0
    var index = -1
//    var headingChanged = false   // only used when headingMode is 'usingWaypontsHeading'

    //
    init(coord: CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coord
        self.title = " "
        self.subtitle = " "
    }
    //
    //    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
    //        self.coordinate = newCoordinate
    //    }
    

}

extension WaypointAnnotation: WaypointAnnotationData {
    func wpt_index() -> Int {
        return self.index
    }
    func wpt_yawAngle() -> CGFloat? {
        return yawAngle
    }
}


class WaypointAnnotationView: MKAnnotationView {
    let numberLabel = UILabel()
    let headingIV = UIImageView()
//    lazy var optView = UIImageView()
    var dragGesture: UILongPressGestureRecognizer? = nil
    var oldDragPt: CGPoint = CGPoint(x: 0, y: 0)

    class func annIdentifier() -> String {
        return "waypoint_Annotation"
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        //            self.isEnabled = false
        self.isDraggable = true
        self.canShowCallout = false

    
        self.image = WaypointUtil.loadImage("waypoint")
        self.centerOffset = CGPoint(x: 0, y: kWaypointAnnotationCenterOff_Y)

        self.alpha = 0.9
        
        


        headingIV.image = WaypointUtil.loadImage("heading")
        let headingWidth: CGFloat = 27
        let headingHeight: CGFloat = headingWidth * 1.2
        headingIV.frame = CGRect(x:(self.frame.width - headingWidth)/2 ,y: self.frame.height - headingHeight/2, width: headingWidth, height: headingHeight)
        headingIV.alpha = 0.95
        self.addSubview(headingIV)
        self.clipsToBounds = false
//        self.sendSubview(toBack: headingIV)

        numberLabel.frame = CGRect(x: 0, y: 3, width: self.frame.width, height: 22)
        numberLabel.backgroundColor = UIColor.clear
        numberLabel.textColor = UIColor.white
        numberLabel.font = UIFont.boldSystemFont(ofSize: 16)
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.textAlignment = .center
        numberLabel.adjustsFontSizeToFitWidth = true
//        numberLabel.isHidden = true
        self.addSubview(numberLabel)
        if let ann = annotation as? WaypointAnnotation {
            numberLabel.text = String(ann.index+1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
////        numberLabel.isHidden = !selected
//        if selected {
////            numberLabel.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0)
////            if !self.contains(self.optView) {
////                self.addSubview(self.optView)
////                self.optView.image = CommonUtility.isIPad() ? UIImage(named: "callout_bg_ipad") : UIImage(named: "callout_bg_ipad")
////                optView.snp.makeConstraints { (make) in
////                    make.centerX.equalToSuperview()
////                    make.centerY.equalToSuperview().offset(-55)
//////                    make.size.width.equalTo( CommonUtility.isIPad() ? 240 : 109 )
//////                    make.size.height.equalTo(CommonUtility.isIPad() ? 70 : 67.6666)
////                }
////
////                let btn1 = UIButton()
////                self.addSubview(btn1)
////                btn1.addTarget(self, action: #selector(tapAdd), for: .touchUpInside)
////                btn1.snp.makeConstraints { (make) in
////                    make.centerX.equalToSuperview().offset(-15)
////                    make.centerY.equalToSuperview().offset(-50)
////                    make.size.width.equalTo(optView.snp.width)
////                    make.size.height.equalTo(optView.snp.height)
////                }
////                btn1.backgroundColor = UIColor.blue
////                self.clipsToBounds = false
////            }
////            self.optView.isHidden = false
//        }else{
////            numberLabel.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
////            self.optView.isHidden = true
//        }
//        print("setSelected")
//    }
    

    

    func updateAnn(ann: WaypointAnnotation) {
        self.annotation = ann
        if let ann = annotation as? WaypointAnnotation {
            numberLabel.text = String(ann.index+1)
        }
    }
    
    func updateNumber() {
        if let n = (self.annotation as? WaypointAnnotation)?.index {
            self.numberLabel.text = "\(n + 1)"
        }
    }

    func clearHeadingAngle() {
        if let wptAnn = self.annotation as? WaypointAnnotation {
            wptAnn.yawAngle = nil
        }
    }
    func updateHeadingAndSave(_ angle: CGFloat) {
        self.updateHeading(angle: angle)
        if let wptAnn = self.annotation as? WaypointAnnotation {
            wptAnn.yawAngle = angle
        }
    }
    func updateHeading(angle: CGFloat) {
        if let wptAnn = self.annotation as? WaypointAnnotation {
//            if checkChanged {
//                if wptAnn.headingChanged {
//                    headingIV.layer.transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
//                    return
//                }
//            }
            
            wptAnn.yawAngle = angle
        }


        headingIV.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    func clear() {
        self.image = nil
        headingIV.removeFromSuperview()
        numberLabel.removeFromSuperview()
        if let gesture = dragGesture {
            self.removeGestureRecognizer(gesture)
        }
    }
    
//    override func setDragState(_ newDragState: MKAnnotationViewDragState, animated: Bool) {
//        super.setDragState(newDragState, animated: animated)
//        print("setDragState")
//
//    }
}

class WaypointCalloutAnnotation: MKPointAnnotation {
    
    var index: Int = -1
    
    //
    init(coord: CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coord
    }
}

class EmptyAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = UIImage(named: "has no image")

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WaypointByAircraftAnnotation: MKPointAnnotation {
    
    //    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    //    var title: String? {return "title"}
    //    var subtitle: String? { return "subtitle"}
    var yawAngle: CGFloat = 0.0
    var index = -1

    //
    init(coord: CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coord
    }
    //
    //    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
    //        self.coordinate = newCoordinate
    //    }
    
}


class WaypointByAircraftAnnotationView: MKAnnotationView {
    let numberLabel = UILabel()
    let headingIV = UIImageView()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        //            self.isEnabled = false

        self.image = UIImage(named: "flightbyaircraft")
        self.centerOffset = CGPoint(x: 0, y: -21)
//        self.showShadow(fr: 2.0, fOpacity: 0.8, offset: CGSize(width: 2, height: 2))
        
        self.alpha = 0.9
        
        headingIV.image = UIImage(named: "aircraft_blue")
        let headingWidth: CGFloat = 24
        let headingHeight: CGFloat = headingWidth * 1.2
        headingIV.frame = CGRect(x:(self.frame.width - headingWidth)/2 ,y: self.frame.height - headingHeight/2, width: headingWidth, height: headingHeight)
        headingIV.alpha = 0.95
        self.addSubview(headingIV)
        self.clipsToBounds = false

        
        numberLabel.frame = CGRect(x: 2, y: 5, width: self.frame.width - 4, height: 20)
        numberLabel.backgroundColor = UIColor.clear
        numberLabel.textColor = UIColor.black
        numberLabel.font = UIFont.boldSystemFont(ofSize: 15)
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.textAlignment = .center
        numberLabel.textColor = UIColor.white
        self.addSubview(numberLabel)

        self.updateNumber()
    }
    
    func updateHeading(angle: Float) {

        headingIV.layer.transform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    func updateNumber() {
        if let n = (self.annotation as? WaypointByAircraftAnnotation)?.index {
            self.numberLabel.text = "\(n + 1)"
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
