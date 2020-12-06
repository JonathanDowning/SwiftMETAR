//
//  METAR+Parsing.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

import Foundation

public extension METAR {

    init?(_ metar: String) {
        self.init(metarString: metar, fullMETAR: true)
    }

    private init?(metarString: String, fullMETAR: Bool = true) {
        var metar = metarString

        guard let icaoRegularExpression = try? NSRegularExpression(pattern: "(.*?)([A-Z0-9]{4})\\b") else { return nil }
        guard let dateRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]{2})([0-9]{2})([0-9]{2})Z\\b") else { return nil }
        guard let tempoBecomingRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(TEMPO|BECMG)(.*)") else { return nil }
        guard let militaryColorCodeRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(BLU|WHT|GRN|YLO1|YLO2|AMB|RED)\\b") else { return nil }
        guard let windRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)([0-9]{3}|VRB)([0-9]{2})(?:G(?:([0-9]{2})|//))?(KT|MPS|KPH)(?: ([0-9]{3})V([0-9]{3}))?\\b") else { return nil }
        guard let cloudsRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(SKC|CLR|NSC|NCD)\\b") else { return nil }
        guard let cloudLayerRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(FEW|SCT|BKN|OVC|VV|///)([0-9]{3}|///)(?:///)?(CB|TCU|///)?") else { return nil }
        guard let temperatureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M)?([0-9]{2})/(?:(?:(M)?([0-9]{2}))|//)?") else { return nil }
        guard let malformedTemperatureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M)?([0-9]{2})/ ") else { return nil }
        guard let visibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(?:(M|P)?([0-9]{4}))(NDV)?\\b") else { return nil }
        guard let metricVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M|P)?([0-9]+)(SM|KM)\\b") else { return nil }
        guard let metricFractionVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M|P)?(?:([0-9]+) )?([0-9]+)/([0-9]+)(SM|KM)\\b") else { return nil }
        guard let directionalVisibilityRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(M|P)?([0-9]{4})(N|NE|E|SE|S|SW|W|NW)\\b") else { return nil }
        guard let weatherRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(-|\\+|VC|RE)?([A-Z]{2})([A-Z]{2})?([A-Z]{2})?\\b") else { return nil }
        guard let pressureRegularExpression = try? NSRegularExpression(pattern: "(?<!\\S)(?:(?:Q([0-9]{4}))|(?:A([0-9]{4})))\\b") else { return nil }
        guard let rvrRegularExpression = try? NSRegularExpression(pattern: "\\bR([0-9]{2}[L|C|R]?)\\/([P|M]?)([0-9]{4})(?:V([P|M]?)([0-9]{4}))?(FT)?(?:/?(U|D|N))?\\b") else { return nil }
        guard let runwayConditionRegularExpression = try? NSRegularExpression(pattern: #"R([0-9]{2}[L|C|R]?)\/(?:(?:([0-9]{1}|\/)([0-9]{1}|\/)([0-9]{2}|\/\/)|(CLRD))(?:([0-9]{2})|\/\/))"#) else { return nil }

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

            dateComponents.timeZone = TimeZone(identifier: "UTC")!
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute

            metar.removeSubrange(dateStringRange)
        } else if fullMETAR {
            return nil
        }

        // MARK: Remarks

        do {
            let components = metar.components(separatedBy: " RMK")
            metar = components.first ?? ""
            let remarks = components.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            self.remarks = remarks.isEmpty ? nil : remarks
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

            guard var forecastMETAR = METAR(metarString: forecastString, fullMETAR: false) else {
                continue
            }
            forecastMETAR.identifier = identifier

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

        trends = forecasts.reversed()

        // MARK: AUTO / CAVOK / COR / NOSIG / Slashes

        do {
            let flags: [String: WritableKeyPath<Self, Bool>] = [
                "AUTO": \.isAutomatic,
                "CAVOK": \.isCeilingAndVisibilityOK,
                "COR": \.isCorrection,
                "NOSIG": \.noSignificantChangesExpected
            ]
            var components = metar.components(separatedBy: .whitespaces)
            for (flag, keyPath) in flags {
                self[keyPath: keyPath] = components.contains(flag)
                components.removeAll { $0 == flag }
            }

            components.removeAll { $0.allSatisfy { $0 == "/" } }
            metar = components.joined(separator: " ")
        }

        // MARK: Runway Visual Range

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

            runwayVisualRanges.insert(.init(runway: String(metar[runwayRange]), visibility: visibility, variableVisibility: variableVisibility, trend: trend), at: 0)

            metar.removeSubrange(range)
        }

        // Runway Conditions

        for match in metar.matches(for: runwayConditionRegularExpression).reversed() {
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

        if let match = metar.matches(for: temperatureRegularExpression).first, let range = match[0], let temperatureRange = match[2], let rawTemperature = Double(String(metar[temperatureRange])) {

            let temperatureIsNegative = match[1] != nil
            let temperature = rawTemperature * (temperatureIsNegative ? -1 : 1)

            let dewPointIsNegative = match[3] != nil
            dewPoint = match[4].flatMap { Double(String(metar[$0])) }.map { .init(value: $0 * (dewPointIsNegative ? -1 : 1), unit: .celsius) }

            self.temperature = .init(value: temperature, unit: .celsius)

            metar.removeSubrange(range)
        } else if let match = metar.matches(for: malformedTemperatureRegularExpression).first, let range = match[0], let temperatureRange = match[2], var temperature = Double(String(metar[temperatureRange])) {
            let temperatureIsNegative = match[1] != nil
            temperature *= (temperatureIsNegative ? -1 : 1)
            self.temperature = .init(value: temperature, unit: .celsius)
            metar.removeSubrange(range)
        }

        // MARK: Visibility

        if let match = metar.matches(for: visibilityRegularExpression).first, let range = match[0] {

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
            switch match[3].map({ metar[$0] }) {
            case "KM":
                visibility = Visibility(modifier: modifier, measurement: .init(value: distance, unit: .kilometers))
            case "SM":
                visibility = Visibility(modifier: modifier, measurement: .init(value: distance, unit: .miles))
            default:
                break
            }
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

        for match in metar.matches(for: directionalVisibilityRegularExpression).reversed() {
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

        // MARK: NOAA Flight Rules

        noaaFlightRules = {
            if ceiling.converted(to: .feet).value < 500 {
                return .lifr
            }
            if let visibility = visibility?.measurement.converted(to: .miles).value, visibility < 1 {
                return .lifr
            }
            if ceiling.converted(to: .feet).value < 1000 {
                return .ifr
            }
            if let visibility = visibility?.measurement.converted(to: .miles).value, visibility < 3 {
                return .ifr
            }
            if ceiling.converted(to: .feet).value <= 3000 {
                return .mvfr
            }
            if let visibility = visibility?.measurement.converted(to: .miles).value, visibility <= 5 {
                return .mvfr
            }
            if let visibility = visibility?.measurement.converted(to: .miles).value, visibility > 5, ceiling.converted(to: .feet).value > 3000 {
                return .vfr
            }
            if let skyCondition = skyCondition, [SkyCondition.clear, .noCloudDetected, .noSignificantCloud, .skyClear].contains(skyCondition){
                return .vfr
            }
            if isCeilingAndVisibilityOK {
                return .vfr
            }
            return nil
        }()
    }

}

private extension String {

    func matches(for regularExpression: NSRegularExpression) -> [[Range<String.Index>?]] {
        return regularExpression
            .matches(in: self, range: NSRange(location: 0, length: utf16.count))
            .map { result in (0..<result.numberOfRanges).map { Range(result.range(at: $0), in: self) } }
    }

}