//
//  Trend.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

public enum Trend: Hashable {

    case becoming(METAR)
    case temporary(METAR)
    case noSignificantChangeExpected

}
