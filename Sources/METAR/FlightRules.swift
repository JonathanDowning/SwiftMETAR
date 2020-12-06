//
//  FlightRules.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public enum NOAAFlightRules {
    
    case vfr
    case mvfr
    case ifr
    case lifr
    
}

extension NOAAFlightRules {

    init?(ceilingAndVisibilityOK: Bool, cloudLayers: [CloudLayer], visibility: Measurement<UnitLength>?) {
        guard !ceilingAndVisibilityOK else {
            self = .vfr
            return
        }

        var ceiling = Double.greatestFiniteMagnitude
        for layer in cloudLayers {
            if layer.coverage == .notReported, let height = layer.height?.converted(to: .feet).value, height <= 3000 {
                return nil
            }
            guard layer.coverage == .overcast || layer.coverage == .skyObscured || layer.coverage == .broken else {
                continue
            }
            guard let height = layer.height?.converted(to: .feet).value else {
                return nil
            }
            if ceiling > height {
                ceiling = height
            }
        }

        if ceiling > 3000, visibility?.converted(to: .miles).value ?? .zero > 5 {
            self = .vfr
        } else if visibility?.converted(to: .miles).value ?? .greatestFiniteMagnitude < 1 || ceiling < 500 {
            self = .lifr
        } else if visibility?.converted(to: .miles).value ?? .greatestFiniteMagnitude < 3 || ceiling < 1000 {
            self = .ifr
        } else if visibility?.converted(to: .miles).value ?? .greatestFiniteMagnitude <= 5 || ceiling <= 3000 {
            self = .mvfr
        } else {
            return nil
        }
    }

}
