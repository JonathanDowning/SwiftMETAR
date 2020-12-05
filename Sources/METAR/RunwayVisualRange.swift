//
//  RunwayVisualRange.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public struct RunwayVisualRange: Equatable, CustomStringConvertible {

    public enum Trend: CustomStringConvertible {
        case decreasing
        case notChanging
        case increasing

        public var description: String {
            switch self {
            case .decreasing:
                return "Decreasing"
            case .notChanging:
                return "Not Changing"
            case .increasing:
                return "Increasing"
            }
        }
    }

    public var runway: String
    public var visibility: Visibility
    public var variableVisibility: Visibility?
    public var trend: Trend?

    public var description: String {
        var description = "Runway \(runway): \(visibility)"
        if let variableVisibility = variableVisibility {
            description += " – \(variableVisibility)"
        }
        if let trend = trend {
            description += " \(trend)"
        }
        return description
    }

}
