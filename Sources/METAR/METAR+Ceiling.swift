//
//  METAR+Ceiling.swift
//
//
//  Created by Jonathan Downing on 07/01/2017.
//

import Foundation

extension METAR {

    var ceiling: Measurement<UnitLength> {
        var ceiling: Double = .greatestFiniteMagnitude
        for layer in cloudLayers {
            guard layer.coverage == .overcast || layer.coverage == .skyObscured || layer.coverage == .broken else {
                continue
            }
            guard let height = layer.height?.converted(to: .feet).value else {
                continue
            }
            if ceiling > height {
                ceiling = height
            }
        }
        return .init(value: ceiling, unit: .feet)
    }

}
