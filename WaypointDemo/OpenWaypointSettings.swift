//
//  OpenWaypointSettings.swift
//  OpenWaypoint
//
//  Created by Jeff on 2021/3/16.
//

import Foundation


class OpenWaypointSettings: NSObject {
    
    var curved: Bool = true
    var pitchEnabled: Bool = false
//    var heading:
    var draggable: Bool = true


    override init() {
        self.curved = true
    }
}
