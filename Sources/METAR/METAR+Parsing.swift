//
//  METAR+Parsing.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public extension METAR {

    init?(rawMETAR: String) {
        self.init(metar: rawMETAR, fullMETAR: true)
    }

    private init?(metar: String, fullMETAR: Bool = true) {
        var metar = metar

        guard let icaoRegularExpression = try? NSRegularExpression(pattern: "(.*?)([A-Z0-9]{4})\\b") else { return nil }
        guard let dateRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]{2})([0-9]{2})([0-9]{2})Z\\b") else { return nil }
        guard let remarksRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)RMK(.*)") else { return nil }
        guard let tempoBecomingRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(TEMPO|BECMG)(.*)") else { return nil }
        guard let nosigRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)NOSIG\\b") else { return nil }
        guard let cavokRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)CAVOK\\b") else { return nil }
        guard let militaryColorCodeRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(BLU|WHT|GRN|YLO1|YLO2|AMB|RED)\\b") else { return nil }
        guard let autoRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)AUTO\\b") else { return nil }
        guard let correctionRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)COR\\b") else { return nil }
        guard let windRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]{3}|VRB)([0-9]{2})(?:G([0-9]{2}))?(KT|MPS|KPH)(?: ([0-9]{3})V([0-9]{3}))?\\b") else { return nil }
        guard let cloudsRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(SKC|CLR|NSC|NCD)\\b") else { return nil }
        guard let cloudLayerRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(FEW|SCT|BKN|OVC|VV|///)([0-9]{3}|///)(?:///)?(CB|TCU|///)?") else { return nil }
        guard let temperatureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M)?([0-9]{2})/(M)?([0-9]{2})\\b") else { return nil }
        guard let malformedTemperatureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M)?([0-9]{2})/ ") else { return nil }
        guard let visibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(?:(M|P)?([0-9]{4}))(NDV)?\\b") else { return nil }
        guard let metricVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M|P)?([0-9]+)SM\\b") else { return nil }
        guard let metricFractionVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M|P)?(?:([0-9]+) )?([0-9]+)/([0-9]{1})SM\\b") else { return nil }
        guard let weatherRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(-|\\+|VC|RE)?([A-Z]{2})([A-Z]{2})?([A-Z]{2})?\\b") else { return nil }
        guard let pressureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(?:(?:Q([0-9]{4}))|(?:A([0-9]{4})))\\b") else { return nil }
        guard let rvrRegularExpression = try? NSRegularExpression(pattern: "\\bR([0-9]{2}[L|C|R]?)\\/([P|M]?)([0-9]{4})(?:V([P|M]?)([0-9]{4}))?(FT)?(?:/?(U|D|N))?\\b") else { return nil }

        metarString = metar

        // Lone Slashes Removal

        metar = metar.split(separator: " ").filter { !$0.allSatisfy { $0 == "/" } }.joined(separator: " ")

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
            var calendar = Calendar(identifier: .gregorian)
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

        if let match = metar.matches(for: remarksRegularExpression).first, let range = match[0], let remarksRange = match[1] {

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

        var forecasts = [Trend]()

        for match in metar.matches(for: tempoBecomingRegularExpression).reversed() {
            guard let range = match[0], let forecastRange = match[1] else {
                continue
            }

            var forecastString = String(metar[range])

            forecastString.removeSubrange(forecastString.startIndex..<forecastString.index(forecastString.startIndex, offsetBy: 5))

            forecastString = forecastString.trimmingCharacters(in: .whitespacesAndNewlines)

            guard var forecastMETAR = METAR(metar: forecastString, fullMETAR: false) else {
                continue
            }
            forecastMETAR.identifier = identifier
            forecastMETAR.date = date

            switch metar[forecastRange] {
            case "BECMG":
                forecasts.append(.init(metarRepresentation: forecastMETAR, type: .becoming))
            case "TEMPO":
                forecasts.append(.init(metarRepresentation: forecastMETAR, type: .temporaryForecast))
            default:
                break
            }

            metar.removeSubrange(range)
        }

        trend = forecasts.reversed()

        if let match = metar.matches(for: nosigRegularExpression).first, let range = match[0] {
            noSignificantChangesExpected = true
            metar.removeSubrange(range)
        }

        // MARK: Runway Visual Range

        var rvrs = [RunwayVisualRange]()
        for match in metar.matches(for: rvrRegularExpression).reversed() {
            guard let range = match[0], let runwayRange = match[1], let visibilityValue = match[3].flatMap({ Double(String(metar[$0])) }) else {
                continue
            }

            let unit: UnitLength = match[6].map { metar[$0] } == "FT" ? .feet : .meters

            let visbilityModifier: Visibility.Modifier
            switch match[2].map({ metar[$0] }) {
            case "M":
                visbilityModifier = .lessThan
            case "P":
                visbilityModifier = .greaterThan
            default:
                visbilityModifier = .equalTo
            }

            let visibility = Visibility(modifier: visbilityModifier, measurement: .init(value: visibilityValue, unit: unit))

            let variableVisibility: Visibility? = match[5].flatMap({ Double(String(metar[$0])) }).map { value in
                let variableVisibilityModifier: Visibility.Modifier
                switch match[4].map({ metar[$0] }) {
                case "M":
                    variableVisibilityModifier = .lessThan
                case "P":
                    variableVisibilityModifier = .greaterThan
                default:
                    variableVisibilityModifier = .equalTo
                }
                return .init(modifier: variableVisibilityModifier, measurement: .init(value: value, unit: unit))
            }


            let trend: RunwayVisualRange.Trend?
            switch match[7].map({ metar[$0] }) {
            case "U":
                trend = .increasing
            case "D":
                trend = .decreasing
            case "N":
                trend = .notChanging
            default:
                trend = nil
            }

            rvrs.append(.init(runway: String(metar[runwayRange]), visibility: visibility, variableVisibility: variableVisibility, trend: trend))

            metar.removeSubrange(range)
        }
        self.runwayVisualRanges = rvrs.reversed()

        // MARK: Military Colour Code

        if let match = metar.matches(for: militaryColorCodeRegularExpression).first, let range = match[0], let colourRange = match[1] {
            switch String(metar[colourRange]) {
            case "BLU":
                militaryColorCode = .blue
            case "WHT":
                militaryColorCode = .white
            case "GRN":
                militaryColorCode = .green
            case "YLO1":
                militaryColorCode = .yellow1
            case "YLO2":
                militaryColorCode = .yellow2
            case "AMB":
                militaryColorCode = .amber
            case "RED":
                militaryColorCode = .red
            default:
                break
            }
            metar.removeSubrange(range)
        }

        // MARK: AUTO

        if let match = metar.matches(for: autoRegularExpression).first, let range = match[0] {
            isAutomatic = true
            metar.removeSubrange(range)
        } else {
            isAutomatic = false
        }

        // MARK: COR

        if let match = metar.matches(for: correctionRegularExpression).first, let range = match[0] {
            isCorrection = true
            metar.removeSubrange(range)
        } else {
            isCorrection = false
        }

        // MARK: CAVOK

        if let match = metar.matches(for: cavokRegularExpression).first, let range = match[0] {
            isCeilingAndVisibilityOK = true
            metar.removeSubrange(range)
        } else {
            isCeilingAndVisibilityOK = false
        }

        // MARK: Wind

        if let match = metar.matches(for: windRegularExpression).first, let directionString = match[1].map({ String(metar[$0]) }), let range = match[0], let conversionRange = match[4], let speedRange = match[2], let speed = Double(String(metar[speedRange])) {

            let direction: Wind.Direction
            switch directionString {
            case "VRB":
                direction = .variable
            default:
                direction = .direction(.init(value: Double(directionString) ?? 0, unit: .degrees))
            }

            let speedUnit: UnitSpeed

            switch metar[conversionRange] {
            case "MPS":
                speedUnit = .metersPerSecond
            case "KPH":
                speedUnit = .kilometersPerHour
            default:
                speedUnit = .knots
            }

            let gustSpeed: Measurement<UnitSpeed>?
            if let gustRange = match[3], let gust = Double(String(metar[gustRange])) {
                gustSpeed = .init(value: gust, unit: speedUnit)
            } else {
                gustSpeed = nil
            }

            let variation: Wind.Variation?

            if let variationMinRange = match[5], let variationMaxRange = match[6], let min = Double(String(metar[variationMinRange])), let max = Double(String(metar[variationMaxRange])) {
                variation = Wind.Variation(from: .init(value: min, unit: .degrees), to: .init(value: max, unit: .degrees))
            } else {
                variation = nil
            }

            wind = Wind(direction: direction, speed: .init(value: speed, unit: speedUnit), gustSpeed: gustSpeed, variation: variation)

            metar.removeSubrange(range)
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

            cloudLayers = cloudLayerMatches.compactMap { match in

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

                return CloudLayer(coverage: coverage, height: cloudHeight.map { .init(value: $0, unit: .feet) }, significantCloudType: significantCloud)
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

            self.temperature = .init(value: temperature, unit: .celsius)
            self.dewPoint = .init(value: dewPoint, unit: .celsius)

            metar.removeSubrange(range)
        } else if let match = metar.matches(for: malformedTemperatureRegularExpression).first, let range = match[0], let temperatureRange = match[2], var temperature = Double(String(metar[temperatureRange])) {
            let temperatureIsNegative = match[1] != nil
            temperature *= (temperatureIsNegative ? -1 : 1)
            self.temperature = .init(value: temperature, unit: .celsius)
            self.dewPoint = nil
            metar.removeSubrange(range)
        }

        // MARK: Visibility

        if let match = metar.matches(for: visibilityRegularExpression).first, let range = match[0] {

            let modifier: Visibility.Modifier
            switch match[1].map({ String(metar[$0]) }) {
            case "M":
                modifier = .lessThan
            case "P":
                modifier = .greaterThan
            default:
                modifier = .equalTo
            }

            if let value = match[2].flatMap({ Double(String(metar[$0])) }) {
                if value == 9999 {
                    visibility = .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers))
                } else {
                    visibility = Visibility(modifier: modifier, measurement: .init(value: value, unit: .meters))
                }
            } else {
                visibility = nil
            }

            metar.removeSubrange(range)
        } else if let match = metar.matches(for: metricVisibilityRegularExpression).first, let range = match[0], let visibilityRange = match[2], let distance = Double(String(metar[visibilityRange])) {
            let modifier: Visibility.Modifier
            switch match[1].map({ String(metar[$0]) }) {
            case "M":
                modifier = .lessThan
            case "P":
                modifier = .greaterThan
            default:
                modifier = .equalTo
            }
            visibility = Visibility(modifier: modifier, measurement: .init(value: distance, unit: .miles))
            metar.removeSubrange(range)
        } else if let match = metar.matches(for: metricFractionVisibilityRegularExpression).first, let range = match[0], let numeratorRange = match[3], let denominatorRange = match[4], let numerator = Double(String(metar[numeratorRange])), let denominator = Double(String(metar[denominatorRange])), denominator > 0 {

            let wholeNumber = match[2].flatMap { Double(String(metar[$0])) } ?? 0

            let modifier: Visibility.Modifier
            switch match[1].map({ String(metar[$0]) }) {
            case "M":
                modifier = .lessThan
            case "P":
                modifier = .greaterThan
            default:
                modifier = .equalTo
            }

            visibility = .init(modifier: modifier, measurement: .init(value: numerator / denominator + wholeNumber, unit: .miles))

            metar.removeSubrange(range)
        }

        // MARK: Weather

        var weather = [Weather]()

        for match in metar.matches(for: weatherRegularExpression).reversed() {
            let modifier: Weather.Modifier
            switch match[1].map({ String(metar[$0]) }) {
            case "+":
                modifier = .heavy
            case "-":
                modifier = .light
            case "RE":
                modifier = .recent
            case "VC":
                modifier = .inTheVicinity
            default:
                modifier = .moderate
            }

            let weatherStrings: [String] = match.suffix(from: 2).compactMap {
                if let weatherStringRange = $0 {
                    return String(metar[weatherStringRange])
                } else {
                    return nil
                }
            }

            let parseWeatherStrings = { (strings: [String]) -> [Weather.Phenomena]? in
                let phenomena = strings.compactMap { string -> Weather.Phenomena? in
                    switch string {
                    case "MI":
                        return .shallow
                    case "PR":
                        return .partial
                    case "BC":
                        return .patches
                    case "DR":
                        return .lowDrifting
                    case "BL":
                        return .blowing
                    case "SH":
                        return .showers
                    case "TS":
                        return .thunderstorm
                    case "FZ":
                        return .freezing
                    case "DZ":
                        return .drizzle
                    case "RA":
                        return .rain
                    case "SN":
                        return .snow
                    case "SG":
                        return .snowGrains
                    case "IC":
                        return .iceCrystals
                    case "PL":
                        return .icePellets
                    case "GR":
                        return .hail
                    case "GS":
                        return .snowPellets
                    case "UP":
                        return .unknownPrecipitation
                    case "BR":
                        return .mist
                    case "FG":
                        return .fog
                    case "FU":
                        return .smoke
                    case "VA":
                        return .volcanicAsh
                    case "SA":
                        return .sand
                    case "HZ":
                        return .haze
                    case "PY":
                        return .spray
                    case "DU":
                        return .widespreadDust
                    case "DS":
                        return .duststorm
                    case "SS":
                        return .sandstorm
                    case "SQ":
                        return .squalls
                    case "FC":
                        return .funnelCloud
                    case "PO":
                        return .wellDevelopedDustWhirls
                    default:
                        return nil
                    }
                }

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

        for match in metar.matches(for: pressureRegularExpression).reversed() {
            guard let range = match[0] else { continue }
            let hPa = match[1].flatMap { Double(String(metar[$0])) }.map { Measurement(value: $0, unit: UnitPressure.hectopascals) }
            let inHg = match[2].flatMap { Double(String(metar[$0])) }.map { Measurement(value: $0 / 100, unit: UnitPressure.inchesOfMercury) }
            if qnh?.unit == .inchesOfMercury {
                qnh = inHg ?? qnh
            } else {
                qnh = inHg ?? hPa ?? qnh
            }
            metar.removeSubrange(range)
        }

        metar = metar.trimmingCharacters(in: .whitespacesAndNewlines)
        if !metar.isEmpty {
            print(metar, "---------",  metarString)
        }

        flightRules = NOAAFlightRules(ceilingAndVisibilityOK: isCeilingAndVisibilityOK, cloudLayers: cloudLayers, visibility: visibility?.measurement)
    }

}

private extension String {

    func matches(for regularExpression: NSRegularExpression) -> [[Range<String.Index>?]] {
        return regularExpression
            .matches(in: self, range: NSRange(location: 0, length: utf16.count))
            .map { result in (0..<result.numberOfRanges).map { Range(result.range(at: $0), in: self) } }
    }

}
