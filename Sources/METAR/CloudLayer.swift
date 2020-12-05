//
//  CloudLayer.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public struct CloudLayer: Equatable {

    public enum Coverage {
        case few
        case scattered
        case broken
        case overcast
        case skyObscured
        case notReported
    }

    public enum SignificantCloudType {
        case cumulonimbus
        case toweringCumulus
    }

    public var coverage: Coverage
    public var height: Measurement<UnitLength>?
    public var significantCloudType: SignificantCloudType?

}
