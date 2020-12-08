//
//  File.swift
//  
//
//  Created by Jonathan Downing on 12/6/20.
//

import Foundation

extension METAR {

    public var icaoFlightRules: ICAOFlightRules? {
        if ceiling.converted(to: .feet).value < 1500 {
            return .imc
        }
        if let visibility = visibility?.measurement.converted(to: .meters).value {
            return visibility < 5000 ? .imc : .vmc
        }
        return .vmc
    }

    public var noaaFlightRules: NOAAFlightRules? {
        if ceiling.converted(to: .feet).value < 500 {
            return .lifr
        }
        if let visibility = visibility?.measurement.converted(to: .miles).value, visibility < 1 {
            return .lifr
        }
        if ceiling.converted(to: .feet).value < 1000 {
            return .ifr
        }
        if let visibility = visibility?.measurement.converted(to: .miles).value, visibility < 3 {
            return .ifr
        }
        if ceiling.converted(to: .feet).value <= 3000 {
            return .mvfr
        }
        if let visibility = visibility?.measurement.converted(to: .miles).value, visibility <= 5 {
            return .mvfr
        }
        if let visibility = visibility?.measurement.converted(to: .miles).value, visibility > 5, ceiling.converted(to: .feet).value > 3000 {
            return .vfr
        }
        if skyCondition == .ceilingAndVisibilityOK {
            return .vfr
        }
        return nil
    }

}
