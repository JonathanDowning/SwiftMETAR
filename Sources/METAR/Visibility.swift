//
//  Visibility.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public struct Visibility: Equatable, CustomStringConvertible {

    public enum Modifier {
        case lessThan, equalTo, greaterThan
    }

    public var modifier: Modifier = .equalTo
    public var measurement: Measurement<UnitLength>

    public var description: String {
        switch modifier {
        case .lessThan:
            return "<\(measurement)"
        case .equalTo:
            return "\(measurement)"
        case .greaterThan:
            return ">\(measurement)"
        }
    }

}
