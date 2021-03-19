//
//  WaypointMapHandler.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/17.
//

import Foundation
import MapKit


class WaypointMapHandler: NSObject,MKMapViewDelegate {
    
    var controllerDelegate: MKMapViewDelegate? = nil
    var userDelegate: MKMapViewDelegate? = nil
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = controllerDelegate?.mapView?(mapView, viewFor: annotation) {
            return annotationView
        }else if let annotationView = userDelegate?.mapView?(mapView, viewFor: annotation) {
            return annotationView
        }else{
            return nil
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderer = controllerDelegate?.mapView?(mapView, rendererFor: overlay) {
            return renderer
        }else if let renderer = userDelegate?.mapView?(mapView, rendererFor: overlay) {
            return renderer
        }else{
            return MKOverlayRenderer()
        }
    }
}
