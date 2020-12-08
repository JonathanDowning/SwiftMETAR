//
//  METAR+Parsing.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

extension METAR {

    public init?(_ metar: String) {
        self.init(metarString: metar)
    }

    private init?(metarString: String, identifier: String? = nil) {
        var metar = metarString

        // MARK: Remarks

        do {
            let components = metar.components(separatedBy: " RMK")
            metar = components.first ?? ""
            let remarks = components.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            self.remarks = remarks.isEmpty ? nil : remarks
        }

        // MARK: ICAO

        if let identifier = identifier {
            self.identifier = identifier
        } else if let match = metar.matches(for: #"(.*?)([A-Z0-9]{4})\b"#).first, let range = match[0], let identifierRange = match[2] {
            self.identifier = String(metar[identifierRange])
            metar.removeSubrange(range)
        } else {
            return nil
        }

        // MARK: Date

        if let match = metar.matches(for: #"(?<!\S)([0-9]{2})([0-9]{2})([0-9]{2})Z\b"#).first, let timeZone = TimeZone(identifier: "UTC"), let dateStringRange = match[0], let dayRange = match[1], let hourRange = match[2], let minuteRange = match[3], let day = Int(String(metar[dayRange])), let hour = Int(String(metar[hourRange])), let minute = Int(String(metar[minuteRange])) {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone

            self.dateComponents.timeZone = TimeZone(identifier: "UTC")!
            self.dateComponents.day = day
            self.dateComponents.hour = hour
            self.dateComponents.minute = minute

            metar.removeSubrange(dateStringRange)
        } else if identifier == nil {
            return nil
        }

        // MARK: TEMPO BECMG

        for match in metar.matches(for: #"(?<!\S)(TEMPO|BECMG|NOSIG)(.*)"#).reversed() {
            guard let range = match[0], let forecastRange = match[1], let forecastString = match[2].map({ String(metar[$0] )}) else {
                continue
            }

            switch metar[forecastRange] {
            case "BECMG":
                guard let forecastMETAR = METAR(metarString: forecastString, identifier: self.identifier) else {
                    continue
                }
                trends.insert(.becoming(forecastMETAR), at: 0)
            case "TEMPO":
                guard let forecastMETAR = METAR(metarString: forecastString, identifier: self.identifier) else {
                    continue
                }
                trends.insert(.temporary(forecastMETAR), at: 0)
            case "NOSIG":
                trends.insert(.noSignificantChangeExpected, at: 0)
            default:
                continue
            }

            metar.removeSubrange(range)
        }

        // MARK: AUTO / CAVOK / COR / NOSIG / Slashes

        do {
            var components = metar.components(separatedBy: .whitespaces)

            let flags = [
                "AUTO": \METAR.isAutomatic,
                "CAVOK": \.isCeilingAndVisibilityOK,
                "COR": \.isCorrection
            ]
            for (flag, keyPath) in flags {
                self[keyPath: keyPath] = components.contains(flag)
                components.removeAll { $0 == flag }
            }

            components.removeAll { $0.allSatisfy { $0 == "/" } }

            metar = components.joined(separator: " ")
        }

        // MARK: Runway Visual Range

        for match in metar.matches(for: #"\bR([0-9]{2}[L|C|R]?)\/([P|M]?)([0-9]{4})(?:V([P|M]?)([0-9]{4}))?(FT)?(?:/?(U|D|N))?\b"#).reversed() {
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

            runwayVisualRanges.insert(.init(runway: String(metar[runwayRange]), visibility: visibility, variableVisibility: variableVisibility, trend: trend), at: 0)

            metar.removeSubrange(range)
        }

        // Runway Conditions

        for match in metar.matches(for: #"R([0-9]{2}[L|C|R]?)\/(?:(?:([0-9]{1}|\/)([0-9]{1}|\/)([0-9]{2}|\/\/)|(CLRD))(?:([0-9]{2})|\/\/))"#).reversed() {
            guard let range = match[0] else { continue }

            let runwayDesignation: RunwayCondition.RunwayDesignation
            if let runwayDesignationString = match[1].map({ String(metar[$0]) }) {
                switch runwayDesignationString {
                case "88":
                    runwayDesignation = .allRunways
                case "99":
                    runwayDesignation = .previousRunwayReportRepeated
                default:
                    runwayDesignation = .runway(runwayDesignationString)
                }
            } else {
                continue
            }

            let brakingConditions: RunwayCondition.BrakingConditions
            if let brakingConditionsString = match[6].flatMap({ String(metar[$0]) }) {
                if let brakingConditionsNumber = Int(brakingConditionsString) {
                    switch brakingConditionsNumber {
                    case 1...90:
                        brakingConditions = .frictionCoefficient(Double(brakingConditionsNumber) / 100)
                    case 91:
                        brakingConditions = .poor
                    case 92:
                        brakingConditions = .poorMedium
                    case 93:
                        brakingConditions = .medium
                    case 94:
                        brakingConditions = .mediumGood
                    case 95:
                        brakingConditions = .good
                    case 99:
                        brakingConditions = .unreliableOrNotMeasurable
                    default:
                        continue
                    }
                } else {
                    continue
                }
            } else {
                brakingConditions = .notReported
            }

            guard match[5] == nil else {
                runwayConditions.insert(.init(runwayDesignation: runwayDesignation, reportType: .contaiminationDisappeared(brakingConditions)), at: 0)
                metar.removeSubrange(range)
                continue
            }

            let depositType: RunwayCondition.DepositType
            if let depositTypeString = match[2].map({ String(metar[$0]) }) {
                if let depositTypeNumber = Int(depositTypeString) {
                    switch depositTypeNumber {
                    case 0:
                        depositType = .clearAndDry
                    case 1:
                        depositType = .damp
                    case 2:
                        depositType = .wetOrWaterPatches
                    case 3:
                        depositType = .rimeOrFrost
                    case 4:
                        depositType = .drySnow
                    case 5:
                        depositType = .wetSnow
                    case 6:
                        depositType = .slush
                    case 7:
                        depositType = .ice
                    case 8:
                        depositType = .compactedOrRolledSnow
                    case 9:
                        depositType = .frozenRutsOrRidges
                    default:
                        continue
                    }
                } else if depositTypeString == "/" {
                    depositType = .notReported
                } else {
                    continue
                }
            } else {
                continue
            }

            let contaminationExtent: RunwayCondition.ContaminationExtent
            if let contaminationExtentString = match[3].map({ String(metar[$0]) }) {
                if let contaminationExtentNumber = Int(contaminationExtentString) {
                    switch contaminationExtentNumber {
                    case 1:
                        contaminationExtent = .minimal
                    case 2:
                        contaminationExtent = .low
                    case 5:
                        contaminationExtent = .medium
                    case 9:
                        contaminationExtent = .high
                    default:
                        continue
                    }
                } else if contaminationExtentString == "/" {
                    contaminationExtent = .notReported
                } else {
                    continue
                }
            } else {
                continue
            }

            let depositDepth: RunwayCondition.DepositDepth
            if let depositDepthString = match[4].map({ String(metar[$0]) }) {
                if let depositDepthNumber = Int(depositDepthString) {
                    switch depositDepthNumber {
                    case 0:
                        depositDepth = .minimal
                    case 1...90:
                        depositDepth = .depth(.init(value: Double(depositDepthNumber), unit: .millimeters))
                    case 92:
                        depositDepth = .depth(.init(value: 100, unit: .millimeters))
                    case 93:
                        depositDepth = .depth(.init(value: 150, unit: .millimeters))
                    case 94:
                        depositDepth = .depth(.init(value: 200, unit: .millimeters))
                    case 95:
                        depositDepth = .depth(.init(value: 250, unit: .millimeters))
                    case 96:
                        depositDepth = .depth(.init(value: 300, unit: .millimeters))
                    case 97:
                        depositDepth = .depth(.init(value: 350, unit: .millimeters))
                    case 98:
                        depositDepth = .depth(.init(value: 400, unit: .millimeters))
                    case 99:
                        depositDepth = .runwayNotOperational
                    default:
                        continue
                    }
                } else if depositDepthString == "//" {
                    depositDepth = .depthNotSignificant
                } else {
                    continue
                }
            } else {
                continue
            }

            if depositType == .notReported && contaminationExtent == .notReported && depositDepth == .depthNotSignificant && brakingConditions == .notReported {
                runwayConditions.insert(.init(runwayDesignation: runwayDesignation, reportType: .reportNotUpdated), at: 0)
            } else {
                runwayConditions.insert(.init(runwayDesignation: runwayDesignation, reportType: .default(depositType, contaminationExtent, depositDepth, brakingConditions)), at: 0)
            }

            metar.removeSubrange(range)
        }

        // MARK: Military Colour Code

        if let match = metar.matches(for: #"(?<!\S)(BLU|WHT|GRN|YLO1|YLO2|AMB|RED)\b"#).first, let range = match[0], let colourRange = match[1] {
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

        // MARK: Wind

        if let match = metar.matches(for: #"(?<!\S)([0-9]{3}|VRB)([0-9]{2})(?:G(?:([0-9]{2})|//))?(KT|MPS|KPH)(?: ([0-9]{3})V([0-9]{3}))?\b"#).first, let directionString = match[1].map({ String(metar[$0]) }), let range = match[0], let conversionRange = match[4], let speedRange = match[2], let speed = Double(String(metar[speedRange])) {

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

            var variation: Wind.Variation?
            if let variationMinRange = match[5], let variationMaxRange = match[6], let min = Double(String(metar[variationMinRange])), let max = Double(String(metar[variationMaxRange])) {
                variation = Wind.Variation(from: .init(value: min, unit: .degrees), to: .init(value: max, unit: .degrees))
            }

            wind = .init(
                direction: direction,
                speed: .init(value: speed, unit: speedUnit),
                gustSpeed: match[3].flatMap({ Double(String(metar[$0])) }).map { .init(value: $0, unit: speedUnit) },
                variation: variation
            )

            metar.removeSubrange(range)
        }

        // MARK: Pressure

        for match in metar.matches(for: #"(?<!\S)(?:(?:Q([0-9]{4}))|(?:A([0-9]{4})))\b"#).reversed() {
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

        // MARK: Clouds

        if let match = metar.matches(for: #"(?<!\S)(SKC|CLR|NSC|NCD)\b"#).first, let range = match[0], let cloudStringRange = match[1] {

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
                break
            }

            metar.removeSubrange(range)
        } else {
            let cloudLayerMatches = metar.matches(for: #"(?<!\S)(FEW|SCT|BKN|OVC|VV|///)([0-9]{3}|///)(?:///)?(CB|TCU|///)?"#)

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

                var cloudHeight: Double?
                if let heightRange = match[2], let height = Double(String(metar[heightRange])) {
                    cloudHeight = height * 100
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

        if let match = metar.matches(for: #"(?<!\S)(M)?([0-9]{2})/(?:(?:(M)?([0-9]{2}))|//)?"#).first, let range = match[0], let temperatureRange = match[2], let rawTemperature = Double(String(metar[temperatureRange])) {

            let temperatureIsNegative = match[1] != nil
            let temperature = rawTemperature * (temperatureIsNegative ? -1 : 1)

            let dewPointIsNegative = match[3] != nil
            dewPoint = match[4].flatMap { Double(String(metar[$0])) }.map { .init(value: $0 * (dewPointIsNegative ? -1 : 1), unit: .celsius) }

            self.temperature = .init(value: temperature, unit: .celsius)

            metar.removeSubrange(range)
        } else if let match = metar.matches(for: #"(?<!\S)(M)?([0-9]{2})/ "#).first, let range = match[0], let temperatureRange = match[2], var temperature = Double(String(metar[temperatureRange])) {
            let temperatureIsNegative = match[1] != nil
            temperature *= (temperatureIsNegative ? -1 : 1)
            self.temperature = .init(value: temperature, unit: .celsius)
            metar.removeSubrange(range)
        }

        // MARK: Visibility

        if let match = metar.matches(for: #"(?<!\S)(?:(M|P)?([0-9]{4}))(NDV)?\b"#).first, let range = match[0] {

            if let value = match[2].flatMap({ Double(String(metar[$0])) }) {
                let modifier: Visibility.Modifier
                switch match[1].map({ String(metar[$0]) }) {
                case "M":
                    modifier = .lessThan
                case "P":
                    modifier = .greaterThan
                default:
                    modifier = .equalTo
                }
                if value == 9999 {
                    visibility = .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers))
                } else {
                    visibility = Visibility(modifier: modifier, measurement: .init(value: value, unit: .meters))
                }
                metar.removeSubrange(range)
            }

        } else if let match = metar.matches(for: #"(?<!\S)(M|P)?([0-9]+)(SM|KM)\b"#).first, let range = match[0], let visibilityRange = match[2], let distance = Double(String(metar[visibilityRange])) {
            let modifier: Visibility.Modifier
            switch match[1].map({ String(metar[$0]) }) {
            case "M":
                modifier = .lessThan
            case "P":
                modifier = .greaterThan
            default:
                modifier = .equalTo
            }
            switch match[3].map({ metar[$0] }) {
            case "KM":
                visibility = Visibility(modifier: modifier, measurement: .init(value: distance, unit: .kilometers))
            case "SM":
                visibility = Visibility(modifier: modifier, measurement: .init(value: distance, unit: .miles))
            default:
                break
            }
            metar.removeSubrange(range)
        } else if let match = metar.matches(for: #"(?<!\S)(M|P)?(?:([0-9]+) )?([0-9]+)/([0-9]+)(SM|KM)\b"#).first, let range = match[0], let numeratorRange = match[3], let denominatorRange = match[4], let numerator = Double(String(metar[numeratorRange])), let denominator = Double(String(metar[denominatorRange])), denominator > 0 {

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

            switch match[5].map({ metar[$0] }) {
            case "KM":
                visibility = .init(modifier: modifier, measurement: .init(value: numerator / denominator + wholeNumber, unit: .kilometers))
            case "SM":
                visibility = .init(modifier: modifier, measurement: .init(value: numerator / denominator + wholeNumber, unit: .miles))
            default:
                break
            }

            metar.removeSubrange(range)
        }

        // MARK: Directional Visibilities

        for match in metar.matches(for: #"(?<!\S)(M|P)?([0-9]{4})(N|NE|E|SE|S|SW|W|NW)\b"#).reversed() {
            guard let range = match[0] else { continue }
            guard let visibility = match[2].flatMap({ Double(String(metar[$0])) }) else { continue }

            let modifier: Visibility.Modifier
            switch match[1].map({ String(metar[$0]) }) {
            case "M":
                modifier = .lessThan
            case "P":
                modifier = .greaterThan
            default:
                modifier = .equalTo
            }

            let direction: DirectionalVisibility.Direction
            switch match[3].map({ String(metar[$0]) }) {
            case "N":
                direction = .north
            case "NE":
                direction = .northEast
            case "E":
                direction = .east
            case "SE":
                direction = .southEast
            case "S":
                direction = .south
            case "SW":
                direction = .southWest
            case "W":
                direction = .west
            case "NW":
                direction = .northWest
            default:
                continue
            }

            directionalVisibilities.insert(.init(visibility: .init(modifier: modifier, measurement: .init(value: visibility, unit: .meters)), direction: direction), at: 0)

            metar.removeSubrange(range)
        }

        // MARK: Weather

        for match in metar.matches(for: #"(?<!\S)(-|\+|VC|RE)?([A-Z]{2})([A-Z]{2})?([A-Z]{2})?\b"#).reversed() {
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
                weather.insert(.init(modifier: modifier, phenomena: phenomena), at: 0)
                metar.removeSubrange(range)
            }
        }
    }

}

private extension String {

    func matches(for regularExpression: String) -> [[Range<String.Index>?]] {
        guard let regularExpression = try? NSRegularExpression(pattern: regularExpression) else { return [] }
        return regularExpression
            .matches(in: self, range: NSRange(location: 0, length: utf16.count))
            .map { result in (0..<result.numberOfRanges).map { Range(result.range(at: $0), in: self) } }
    }

}
