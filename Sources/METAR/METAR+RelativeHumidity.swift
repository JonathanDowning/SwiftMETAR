//
//  METAR+RelativeHumidity.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

extension METAR {

    public var relativeHumidity: Double? {
        guard
            let temperature = temperature?.converted(to: .celsius).value,
            let dewPoint = dewPoint?.converted(to: .celsius).value
        else {
            return nil
        }
        return exp((17.625 * dewPoint) / (243.04 + dewPoint)) / exp((17.625 * temperature) / (243.04 + temperature))
    }

}
