//
//  MapAnnotation.swift
//  Dardasha
//
//  Created by Ahmed on 13/10/2022.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
