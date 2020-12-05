//
//  Trend.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

public struct Trend: Equatable {

    public enum `Type` {
        case becoming, temporaryForecast
    }

    public var metarRepresentation: METAR
    public var type: Type

}
