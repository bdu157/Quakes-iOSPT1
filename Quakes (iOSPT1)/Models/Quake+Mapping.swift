//
//  Quake+Mapping.swift
//  Quakes (iOSPT1)
//
//  Created by Dongwoo Pae on 9/26/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import Foundation
import MapKit

extension Quake: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return geometry.location
    }
    
    var title: String? {
        return properties.place
    }
}

