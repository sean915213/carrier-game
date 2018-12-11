//
//  CLAuthorizationStatusExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 6/8/18.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        }
    }
}
