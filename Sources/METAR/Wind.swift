//
//  Wind.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public struct Wind: Hashable {

    public enum Direction: Hashable {
        case direction(Measurement<UnitAngle>)
        case variable
    }

    public struct Variation: Hashable {
        public var from: Measurement<UnitAngle>
        public var to: Measurement<UnitAngle>
    }

    public var direction: Direction
    public var speed: Measurement<UnitSpeed>
    public var gustSpeed: Measurement<UnitSpeed>?
    public var variation: Variation?

}
