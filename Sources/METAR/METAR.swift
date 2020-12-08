//
//  METAR.swift
//
//
//  Created by Jonathan Downing on 07/01/2017.
//

import Foundation

public struct METAR: Hashable {

    public var identifier: String
    public var dateComponents = DateComponents()
    public var wind: Wind?
    public var skyCondition: SkyCondition?
    public var cloudLayers: [CloudLayer] = []
    public var visibility: Visibility?
    public var directionalVisibilities: [DirectionalVisibility] = []
    public var runwayConditions: [RunwayCondition] = []
    public var runwayVisualRanges: [RunwayVisualRange] = []
    public var weather: [Weather] = []
    public var temperature: Measurement<UnitTemperature>?
    public var dewPoint: Measurement<UnitTemperature>?
    public var qnh: Measurement<UnitPressure>?
    public var trends: [Trend] = []
    public var militaryColorCode: MilitaryColorCode?
    public var isCeilingAndVisibilityOK = false
    public var isAutomatic = false
    public var isCorrection = false
    public var remarks: String?

}
