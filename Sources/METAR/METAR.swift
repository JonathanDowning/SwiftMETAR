//
//  METAR.swift
//
//  Created by Jonathan Downing on 07/01/2017.
//  Copyright © 2017 Jonathan Downing. All rights reserved.
//

import Foundation

public struct METAR: Codable {
    
    public let identifier: String
    public let date: Date
    public let wind: Wind?
    public let qnh: QNH?
    public let skyCondition: SkyCondition?
    public let cloudLayers: [CloudLayer]
    public let visibility: Visibility?
    public let weather: [Weather]
    public let trends: [Forecast]
    public let militaryColourCode: MilitaryColourCode?
    public let temperature: Temperature?
    public let dewPoint: Temperature?
    public let relativeHumidity: Double?
    public let ceilingAndVisibilityOK: Bool
    public let automaticStation: Bool
    public let correction: Bool
    public let noSignificantChangesExpected: Bool
    public let remarks: String?
    public let metarString: String
    public let flightRules: NOAAFlightRules?
    
}

extension METAR: Equatable {
    
    public static func == (lhs: METAR, rhs: METAR) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.date == rhs.date &&
            lhs.metarString == rhs.metarString &&
            lhs.wind == rhs.wind &&
            lhs.qnh == rhs.qnh &&
            lhs.skyCondition == rhs.skyCondition &&
            lhs.visibility == rhs.visibility &&
            lhs.weather == rhs.weather &&
            lhs.trends == rhs.trends &&
            lhs.militaryColourCode == rhs.militaryColourCode &&
            lhs.temperature == rhs.temperature &&
            lhs.dewPoint == rhs.dewPoint &&
            lhs.automaticStation == rhs.automaticStation &&
            lhs.noSignificantChangesExpected == rhs.noSignificantChangesExpected &&
            lhs.correction == rhs.correction &&
            lhs.remarks == rhs.remarks &&
            lhs.flightRules == rhs.flightRules
    }
    
}

extension METAR {
    
    static func noaaFlightRules(ceilingAndVisibilityOK: Bool, cloudLayers: [CloudLayer], visibility: Measurement<UnitLength>?) -> NOAAFlightRules? {
        if ceilingAndVisibilityOK {
            return .vfr
        }
        
        let ceiling = cloudLayers
            .filter { $0.coverage == .overcast || $0.coverage == .skyObscured || $0.coverage == .broken }
            .flatMap { $0.height?.measurement.converted(to: .feet).value }
            .sorted()
            .first ?? .greatestFiniteMagnitude
        
        if ceiling > 3000, let visibilityValue = visibility?.converted(to: .miles).value, visibilityValue > 5 {
            return .vfr
        }
        
        if ceiling < 500 {
            return .lifr
        } else if ceiling < 1000 {
            return .ifr
        } else if ceiling <= 3000 {
            return .mvfr
        }
        
        if let visibilityValue = visibility?.converted(to: .miles).value {
            if visibilityValue < 1 {
                return .lifr
            } else if visibilityValue < 3 {
                return .ifr
            } else if visibilityValue <= 5 {
                return .mvfr
            }
        }
        
        return nil
    }
    
}

extension METAR {
    
    public init?(rawMETAR: String) {
        self.init(metar: rawMETAR, fullMETAR: true)
    }
    
    private init?(metar: String, fullMETAR: Bool = true) {
        var metar = metar
        
        guard let loneSlashesRegularExpression = try? NSRegularExpression(pattern: "(^|\\s)(/)+") else { return nil }
        guard let icaoRegularExpression = try? NSRegularExpression(pattern: "(.*?)([A-Z]{4})\\b") else { return nil }
        guard let dateRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]{2})([0-9]{2})([0-9]{2})Z\\b") else { return nil }
        guard let tempoBecomingRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)RMK(.*)") else { return nil }
        guard let nosigRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)NOSIG\\b") else { return nil }
        guard let militaryColorCodeRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(BLU|WHT|GRN|YLO1|YLO2|AMB|RED)\\b") else { return nil }
        guard let autoRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)AUTO\\b") else { return nil }
        guard let correctionRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)COR\\b") else { return nil }
        guard let windRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]{3}|VRB)([0-9]{2})(?:G([0-9]{2}))?(KT|MPS|KPH)(?: ([0-9]{3})V([0-9]{3}))?\\b") else { return nil }
        guard let cloudsRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(SKC|CLR|NSC|NCD)\\b") else { return nil }
        guard let cloudLayerRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(FEW|SCT|BKN|OVC|VV|///)([0-9]{3}|///)(CB|TCU|///)?") else { return nil }
        guard let temperatureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M)?([0-9]{2})/(M)?([0-9]{2})\\b") else { return nil }
        guard let malformedTemperatureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M)?([0-9]{2})/ ") else { return nil }
        guard let visibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(CAVOK|[0-9]{4})(NDV)?\\b") else { return nil }
        guard let metricVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]+)SM\\b") else { return nil }
        guard let metricFractionVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(?:([0-9]+) )?([0-9]+)/([0-9]{1})SM\\b") else { return nil }
        guard let weatherRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(-|\\+|VC|RE)?([A-Z]{2})([A-Z]{2})?([A-Z]{2})?\\b") else { return nil }
        guard let pressureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(?:(?:Q([0-9]{4}))|(?:A([0-9]{4})))\\b") else { return nil }
        
        // Lone Slashes Removal
        
        for match in metar.matches(for: loneSlashesRegularExpression).reversed() {
            guard let range = match[0] else {
                continue
            }
            
            metar.removeSubrange(range)
        }
        
        metarString = metar
        
        // MARK: ICAO
        
        if let match = metar.matches(for: icaoRegularExpression).first, let range = match[0], let identifierRange = match[2], fullMETAR {
            identifier = String(metar[identifierRange])
            metar.removeSubrange(range)
        } else if fullMETAR {
            return nil
        } else {
            identifier = ""
        }
        
        // MARK: Date
        
        if let match = metar.matches(for: dateRegularExpression).first, let timeZone = TimeZone(identifier: "UTC"), let dateStringRange = match[0], let dayRange = match[1], let hourRange = match[2], let minuteRange = match[3], let day = Int(String(metar[dayRange])), let hour = Int(String(metar[hourRange])), let minute = Int(String(metar[minuteRange])) {
            var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            calendar.timeZone = timeZone
            
            var dateComponents = calendar.dateComponents([.year, .month, .day, .timeZone], from: Date())
            
            let currentDay = dateComponents.day!
            
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            if let day = dateComponents.day, currentDay < day, let month = dateComponents.month {
                dateComponents.month = month - 1
            }
            
            if let date = calendar.date(from: dateComponents) {
                self.date = date
                metar.removeSubrange(dateStringRange)
            } else {
                return nil
            }
        } else if fullMETAR {
            return nil
        } else {
            date = Date()
        }
        
        // MARK: Remarks
        
        if let match = metar.matches(for: tempoBecomingRegularExpression).first, let range = match[0], let remarksRange = match[1] {
            
            let remarksString = String(metar[remarksRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !remarksString.isEmpty {
                remarks = remarksString
            } else {
                remarks = nil
            }
            
            metar.removeSubrange(range)
        } else {
            remarks = nil
        }
        
        // MARK: TEMPO BECMG
        
        var forecasts = [Forecast]()
        
        for match in metar.matches(for: tempoBecomingRegularExpression).reversed() {
            guard let range = match[0], let forecastRange = match[1] else {
                continue
            }
            
            var forecastString = String(metar[range])
            
            forecastString.removeSubrange(forecastString.startIndex..<forecastString.index(forecastString.startIndex, offsetBy: 5))
            
            forecastString = forecastString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            guard let forecastMETAR = METAR(metar: forecastString, fullMETAR: false) else {
                continue
            }
            
            switch metar[forecastRange] {
            case "BECMG":
                forecasts.append(Forecast(metarRepresentation: forecastMETAR, type: .becoming))
            case "TEMPO":
                forecasts.append(Forecast(metarRepresentation: forecastMETAR, type: .temporaryForecast))
            default:
                break
            }
            
            metar.removeSubrange(range)
        }
        
        trends = forecasts
        
        if let match = metar.matches(for: nosigRegularExpression).first, let range = match[0] {
            noSignificantChangesExpected = true
            metar.removeSubrange(range)
        } else {
            noSignificantChangesExpected = false
        }
        
        // MARK: Military Colour Code
        
        if let match = metar.matches(for: militaryColorCodeRegularExpression).first, let range = match[0], let colourRange = match[1] {
            switch String(metar[colourRange]) {
            case "BLU":
                militaryColourCode = .blue
            case "WHT":
                militaryColourCode = .white
            case "GRN":
                militaryColourCode = .green
            case "YLO1":
                militaryColourCode = .yellow1
            case "YLO2":
                militaryColourCode = .yellow2
            case "AMB":
                militaryColourCode = .amber
            case "RED":
                militaryColourCode = .red
            default:
                militaryColourCode = nil
            }
            metar.removeSubrange(range)
        } else {
            militaryColourCode = nil
        }
        
        // MARK: AUTO
        
        if let match = metar.matches(for: autoRegularExpression).first, let range = match[0] {
            automaticStation = true
            metar.removeSubrange(range)
        } else {
            automaticStation = false
        }
        
        // MARK: COR
        
        if let match = metar.matches(for: correctionRegularExpression).first, let range = match[0] {
            correction = true
            metar.removeSubrange(range)
        } else {
            correction = false
        }
        
        // MARK: Wind
        
        if let match = metar.matches(for: windRegularExpression).first, let range = match[0], let directionRange = match[1], let conversionRange = match[4], let speedRange = match[2], let speed = Double(String(metar[speedRange])) {
            
            let speedUnit: Wind.Speed.Unit
            
            switch metar[conversionRange] {
            case "MPS":
                speedUnit = .metersPerSecond
            case "KPH":
                speedUnit = .kilometersPerHour
            default:
                speedUnit = .knots
            }
            
            let directionString = String(metar[directionRange])
            
            let gustSpeed: Wind.Speed?
            if let gustRange = match[3], let gust = Double(String(metar[gustRange])) {
                gustSpeed = Wind.Speed(value: gust, unit: speedUnit)
            } else {
                gustSpeed = nil
            }
            
            let variation: Wind.Variation?
            
            if let variationMinRange = match[5], let variationMaxRange = match[6], let min = Double(String(metar[variationMinRange])), let max = Double(String(metar[variationMaxRange])) {
                variation = Wind.Variation(from: min, to: max)
            } else {
                variation = nil
            }
            
            wind = Wind(direction: Double(directionString), speed: Wind.Speed(value: speed, unit: speedUnit), gustSpeed: gustSpeed, variation: variation)
            
            metar.removeSubrange(range)
        } else {
            wind = nil
        }
        
        // MARK: Clouds
        
        if let match = metar.matches(for: cloudsRegularExpression).first, let range = match[0], let cloudStringRange = match[1] {
            
            switch metar[cloudStringRange] {
            case "SKC":
                skyCondition = .skyClear
            case "CLR":
                skyCondition = .clear
            case "NSC":
                skyCondition = .noSignificantCloud
            case "NCD":
                skyCondition = .noCloudDetected
            default:
                skyCondition = nil
            }
            
            cloudLayers = []
            
            metar.removeSubrange(range)
        } else {
            let cloudLayerMatches = metar.matches(for: cloudLayerRegularExpression)
            
            skyCondition = nil
            
            cloudLayers = cloudLayerMatches.flatMap { match in
                
                guard let typeRange = match[1] else {
                    return nil
                }
                
                let type = (metar[typeRange])
                
                let significantCloudTypeString: String?
                if let significantCloudRange = match[3] {
                    significantCloudTypeString = String(metar[significantCloudRange])
                } else {
                    significantCloudTypeString = nil
                }
                
                let cloudHeight: Double?
                
                if let heightRange = match[2], let height = Double(String(metar[heightRange])) {
                    cloudHeight = height * 100
                } else {
                    cloudHeight = nil
                }
                
                let coverage: CloudLayer.Coverage
                
                switch type {
                case "FEW":
                    coverage = .few
                case "SCT":
                    coverage = .scattered
                case "BKN":
                    coverage = .broken
                case "OVC":
                    coverage = .overcast
                case "VV":
                    coverage = .skyObscured
                default:
                    coverage = .notReported
                }
                
                let significantCloud: CloudLayer.SignificantCloudType?
                
                switch significantCloudTypeString {
                case "CB"?:
                    significantCloud = .cumulonimbus
                case "TCU"?:
                    significantCloud = .toweringCumulus
                default:
                    significantCloud = nil
                }
                
                return CloudLayer(coverage: coverage, height: cloudHeight.map { CloudLayer.Height(value: $0, unit: .feet) }, significantCloudType: significantCloud)
            }
            
            for match in cloudLayerMatches.reversed() {
                if let range = match[0] {
                    metar.removeSubrange(range)
                }
            }
        }
        
        // MARK: Temperatures
        
        if let match = metar.matches(for: temperatureRegularExpression).first, let range = match[0], let temperatureRange = match[2], let rawTemperature = Double(String(metar[temperatureRange])), let dewPointRange = match[4], let rawDewPoint = Double(String(metar[dewPointRange])) {
            
            let temperatureIsNegative = match[1] != nil
            let temperature = rawTemperature * (temperatureIsNegative ? -1 : 1)
            
            let dewPointIsNegative = match[3] != nil
            let dewPoint = rawDewPoint * (dewPointIsNegative ? -1 : 1)
            
            self.temperature = Temperature(value: temperature, unit: .celsius)
            self.dewPoint = Temperature(value: dewPoint, unit: .celsius)
            
            metar.removeSubrange(range)
        } else if let match = metar.matches(for: malformedTemperatureRegularExpression).first, let range = match[0], let temperatureRange = match[2], var temperature = Double(String(metar[temperatureRange])) {
            let temperatureIsNegative = match[1] != nil
            temperature *= (temperatureIsNegative ? -1 : 1)
            self.temperature = Temperature(value: temperature, unit: .celsius)
            self.dewPoint = nil
            metar.removeSubrange(range)
        } else {
            self.temperature = nil
            self.dewPoint = nil
        }
        
        // MARK: Visibility
        
        let visibility: Visibility?
        
        if let match = metar.matches(for: visibilityRegularExpression).first, let range = match[0], let visibilityRange = match[1] {
            
            let visibilityString = String(metar[visibilityRange])
            
            if visibilityString == "CAVOK" {
                visibility = nil
                ceilingAndVisibilityOK = true
            } else if visibilityString == "9999" {
                visibility = Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true)
                ceilingAndVisibilityOK = false
            } else if let distance = Double(visibilityString) {
                visibility = Visibility(value: distance, unit: .meters, greaterThanOrEqual: false)
                ceilingAndVisibilityOK = false
            } else {
                visibility = nil
                ceilingAndVisibilityOK = false
            }
            
            metar.removeSubrange(range)
        } else if let match = metar.matches(for: metricVisibilityRegularExpression).first, let range = match[0], let visibilityRange = match[1], let distance = Double(String(metar[visibilityRange])) {
            visibility = Visibility(value: distance, unit: .miles, greaterThanOrEqual: false)
            ceilingAndVisibilityOK = false
            metar.removeSubrange(range)
        } else if let match = metar.matches(for: metricFractionVisibilityRegularExpression).first, let range = match[0], let numeratorRange = match[2], let denominatorRange = match[3], let numerator = Double(String(metar[numeratorRange])), let denominator = Double(String(metar[denominatorRange])), denominator > 0 {
            
            let wholeNumber = match[1].flatMap { Double(String(metar[$0])) } ?? 0
            
            visibility = Visibility(value: numerator / denominator + wholeNumber, unit: .miles, greaterThanOrEqual: false)
            
            ceilingAndVisibilityOK = false
            
            metar.removeSubrange(range)
        } else {
            ceilingAndVisibilityOK = false
            
            visibility = nil
        }
        
        self.visibility = visibility
        
        // MARK: Weather
        
        var weather = [Weather]()
        
        for match in metar.matches(for: weatherRegularExpression).reversed() {
            let modifier: Weather.Modifier
            
            if let modifierRange = match[1], let modifierCode = Weather.Modifier(rawValue: String(metar[modifierRange])) {
                modifier = modifierCode
            } else {
                modifier = .moderate
            }
            
            let weatherStrings: [String] = match.suffix(from: 2).flatMap {
                if let weatherStringRange = $0 {
                    return String(metar[weatherStringRange])
                } else {
                    return nil
                }
            }
            
            let parseWeatherStrings = { (strings: [String]) -> [Weather.Phenomena]? in
                let phenomena = strings.flatMap { Weather.Phenomena(rawValue: $0) }
                
                if phenomena.count != strings.count {
                    return nil
                }
                
                return phenomena
            }
            
            if let phenomena = parseWeatherStrings(weatherStrings), let range = match[0] {
                weather.append(Weather(modifier: modifier, phenomena: phenomena))
                metar.removeSubrange(range)
            }
        }
        
        self.weather = weather.reversed()
        
        // MARK: Pressure
        
        if let match = metar.matches(for: pressureRegularExpression).first, let range = match[0] {
            
            if let qnhRange = match[1], let qnh = Double(String(metar[qnhRange])) {
                self.qnh = QNH(value: qnh, unit: .hectopascals)
                metar.removeSubrange(range)
            } else if let altimeterRange = match[2], let altimeter = Double(String(metar[altimeterRange])).map({ $0 / 100 }) {
                self.qnh = QNH(value: altimeter, unit: .inchesOfMercury)
                metar.removeSubrange(range)
            } else {
                qnh = nil
            }
        } else {
            qnh = nil
        }
        
        if let temperature = temperature?.measurement.converted(to: .celsius).value, let dewPoint = dewPoint?.measurement.converted(to: .celsius).value {
            relativeHumidity = exp((17.625 * dewPoint) / (243.04 + dewPoint)) / exp((17.625 * temperature) / (243.04 + temperature))
        } else {
            relativeHumidity = nil
        }
        
        self.flightRules = METAR.noaaFlightRules(ceilingAndVisibilityOK: self.ceilingAndVisibilityOK, cloudLayers: self.cloudLayers, visibility: self.visibility?.measurement)
    }
    
}

public struct QNH: Equatable, Codable {
    
    enum Unit: String, Codable {
        case hectopascals
        case inchesOfMercury
    }
    
    let value: Double
    let unit: Unit
    
    public var measurement: Measurement<UnitPressure> {
        switch unit {
        case .hectopascals:
            return Measurement(value: value, unit: .hectopascals)
        case .inchesOfMercury:
            return Measurement(value: value, unit: .inchesOfMercury)
        }
    }
    
    public static func == (lhs: QNH, rhs: QNH) -> Bool {
        return lhs.measurement == rhs.measurement
    }
    
}

public struct Temperature: Equatable, Codable {
    
    enum Unit: String, Codable {
        case celsius
    }
    
    let value: Double
    let unit: Unit
    
    public var measurement: Measurement<UnitTemperature> {
        switch unit {
        case .celsius:
            return Measurement(value: value, unit: .celsius)
        }
    }
    
    public static func == (lhs: Temperature, rhs: Temperature) -> Bool {
        return lhs.measurement == rhs.measurement
    }
    
}

public struct Visibility: Equatable, Codable {
    
    public enum Unit: String, Codable {
        case kilometers
        case meters
        case miles
    }
    
    public let value: Double
    public let unit: Unit
    public let greaterThanOrEqual: Bool
    
    public static func == (lhs: Visibility, rhs: Visibility) -> Bool {
        return lhs.measurement == rhs.measurement && lhs.greaterThanOrEqual == rhs.greaterThanOrEqual
    }
    
    public var measurement: Measurement<UnitLength> {
        switch unit {
        case .kilometers:
            return Measurement(value: value, unit: .kilometers)
        case .meters:
            return Measurement(value: value, unit: .meters)
        case .miles:
            return Measurement(value: value, unit: .miles)
        }
    }
    
}

public struct Wind: Equatable, Codable {
    
    public struct Speed: Codable {
        
        public enum Unit: String, Codable {
            case knots
            case metersPerSecond
            case kilometersPerHour
        }
        
        public let value: Double
        public let unit: Unit
        
        public static func == (lhs: Speed, rhs: Speed) -> Bool {
            return lhs.measurement == rhs.measurement
        }
        
        public var measurement: Measurement<UnitSpeed> {
            switch unit {
            case .knots:
                return Measurement(value: value, unit: .knots)
            case .metersPerSecond:
                return Measurement(value: value, unit: .metersPerSecond)
            case .kilometersPerHour:
                return Measurement(value: value, unit: .kilometersPerHour)
            }
        }
        
    }
    
    public typealias Degrees = Double
    
    public let direction: Degrees?
    public let speed: Speed
    public let gustSpeed: Speed?
    public let variation: Variation?
    
    public struct Variation: Equatable, Codable {
        
        public let from: Degrees
        public let to: Degrees
        
        public static func == (lhs: Wind.Variation, rhs: Wind.Variation) -> Bool {
            return lhs.from == rhs.from && lhs.to == rhs.to
        }
        
    }
    
    public static func == (lhs: Wind, rhs: Wind) -> Bool {
        return lhs.direction == rhs.direction &&
            lhs.speed == rhs.speed &&
            lhs.gustSpeed?.measurement == rhs.gustSpeed?.measurement &&
            lhs.variation == rhs.variation
    }
    
}

public enum SkyCondition: String, Codable {
    case clear
    case noCloudDetected
    case noSignificantCloud
    case skyClear
}

public struct CloudLayer: Equatable, Codable {
    
    public struct Height: Equatable, Codable {
        
        enum Unit: String, Codable {
            case feet
        }
        
        let value: Double
        let unit: Unit
        
        public var measurement: Measurement<UnitLength> {
            switch unit {
            case .feet:
                return Measurement(value: value, unit: .feet)
            }
        }
        
        public static func == (lhs: Height, rhs: Height) -> Bool {
            return lhs.measurement == rhs.measurement
        }
        
    }
    
    public let coverage: Coverage
    public let height: Height?
    public let significantCloudType: SignificantCloudType?
    
    public enum Coverage: String, Codable {
        case few, scattered, broken, overcast, skyObscured, notReported
    }
    
    public enum SignificantCloudType: String, Codable {
        case cumulonimbus, toweringCumulus
    }
    
    public static func == (lhs: CloudLayer, rhs: CloudLayer) -> Bool {
        return lhs.coverage == rhs.coverage && lhs.height?.measurement == rhs.height?.measurement && lhs.significantCloudType == rhs.significantCloudType
    }
    
}

public struct Weather: Equatable, Codable {
    
    public let modifier: Modifier
    public let phenomena: [Phenomena]
    
    public enum Modifier: String, Codable {
        case light = "-"
        case moderate
        case heavy = "+"
        case inTheVicinity = "VC"
        case recent = "RE"
    }
    
    public enum Phenomena: String, Codable {
        case shallow = "MI"
        case partial = "PR"
        case patches = "BC"
        case lowDrifting = "DR"
        case blowing = "BL"
        case showers = "SH"
        case thunderstorm = "TS"
        case freezing = "FZ"
        case drizzle = "DZ"
        case rain = "RA"
        case snow = "SN"
        case snowGrains = "SG"
        case iceCrystals = "IC"
        case icePellets = "PL"
        case hail = "GR"
        case snowPellets = "GS"
        case unknownPrecipitation = "UP"
        case mist = "BR"
        case fog = "FG"
        case smoke = "FU"
        case volcanicAsh = "VA"
        case sand = "SA"
        case haze = "HZ"
        case spray = "PY"
        case widespreadDust = "DU"
        case duststorm = "DS"
        case sandstorm = "SS"
        case squalls = "SQ"
        case funnelCloud = "FC"
        case wellDevelopedDustWhirls = "PO"
    }
    
    public static func == (lhs: Weather, rhs: Weather) -> Bool {
        return lhs.modifier == rhs.modifier && lhs.phenomena == rhs.phenomena
    }
    
}

public enum MilitaryColourCode: String, Codable {
    case blue
    case white
    case green
    case yellow1
    case yellow2
    case amber
    case red
}

public struct Forecast: Equatable, Codable {
    
    public enum `Type`: String, Codable {
        case becoming = "BECMG", temporaryForecast = "TEMPO"
    }
    
    public let metarRepresentation: METAR
    public let type: Type
    
    public static func == (lhs: Forecast, rhs: Forecast) -> Bool {
        return lhs.metarRepresentation == rhs.metarRepresentation && lhs.type == rhs.type
    }
    
}

public enum NOAAFlightRules: String, Codable {
    case vfr
    case mvfr
    case ifr
    case lifr
}

extension String {
    
    fileprivate func matches(for regularExpression: NSRegularExpression) -> [[Range<String.Index>?]] {
        return regularExpression
            .matches(in: self, range: NSRange(location: 0, length: utf16.count))
            .map { result in (0..<result.numberOfRanges).map { Range(result.range(at: $0), in: self) } }
    }
    
}
