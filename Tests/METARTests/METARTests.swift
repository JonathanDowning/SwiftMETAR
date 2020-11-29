import XCTest
@testable import METAR

final class METARTests: XCTestCase {

    func testDatelessMETAR() {
        let metarString = "KRDU 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"
        let metar = METAR(rawMETAR: metarString)
        XCTAssertNil(metar)
    }

    func testSimpleMETAR() throws {
        try compareMETAR("KRDU COR 281151Z AUTO 22007KT 9SM SCT040TCU FEW080 FEW250 22/20 SHRA BLU A3004 NOSIG RMK AO2 SLP166 60000 T02170200 10222 20206 53022", "KRDU", 28, 11, 51, wind: Wind(direction: 220, speed: .init(value: 7, unit: .knots)), qnh: QNH(value: 30.04, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .scattered, height: .init(value: 4000, unit: .feet), significantCloudType: .toweringCumulus), .init(coverage: .few, height: .init(value: 8000, unit: .feet)), .init(coverage: .few, height: .init(value: 25000, unit: .feet))], visibility: Visibility(value: 9, unit: .miles), weather: [Weather(modifier: .moderate, phenomena: [.showers, .rain])], militaryColourCode: .blue, temperature: Temperature(value: 22, unit: .celsius), dewPoint: Temperature(value: 20, unit: .celsius), automaticStation: true, correction: true, noSignificantChangesExpected: true, remarks: "AO2 SLP166 60000 T02170200 10222 20206 53022", flightRules: .vfr)
    }

    func testMETARs() throws {
        try compareMETAR("EGGD 121212Z ///010 10SM", "EGGD", 12, 12, 12, cloudLayers: [.init(coverage: .notReported, height: .init(value: 1000, unit: .feet))], visibility: .init(value: 10, unit: .miles))
        try compareMETAR("EGGD 121212Z ///010 1 1/4SM", "EGGD", 12, 12, 12, cloudLayers: [.init(coverage: .notReported, height: .init(value: 1000, unit: .feet))], visibility: .init(value: 1.25, unit: .miles))
    }

    func testSlashesInBetweenCloudTypeAndHeight() throws {
        let metarString = "EGGD 251250Z AUTO 25016G27KT 220V280 9999 BKN019///TCU 11/11 Q1013"
        let metar = METAR(rawMETAR: metarString)
        let testMETAR = METAR(
            identifier: "EGGD",
            date: date(day: 25, hour: 12, minute: 50),
            wind: Wind(direction: 250, speed: .init(value: 16, unit: .knots), gustSpeed: .init(value: 27, unit: .knots), variation: .init(from: 220, to: 280)),
            qnh: QNH(value: 1013, unit: .hectopascals),
            cloudLayers: [
                CloudLayer(coverage: .broken, height: .init(value: 1900, unit: .feet), significantCloudType: .toweringCumulus)
            ],
            visibility: Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true),
            temperature: Temperature(value: 11, unit: .celsius),
            dewPoint: Temperature(value: 11, unit: .celsius),
            automaticStation: true,
            metarString: metarString,
            flightRules: .mvfr
        )

        try XCTAssertEqual(XCTUnwrap(metar), XCTUnwrap(testMETAR))
    }

    func testTEMPO() throws {
        let metarString = "UUDD 261100Z 25007MPS 200V290 9999 BKN026 14/08 Q0997 R88/290095 TEMPO 28012G18MPS 1500 TSRA BKN015CB RMK TEST REMARKS"
        let metar = METAR(rawMETAR: metarString)
        let testMETAR = METAR(
            identifier: "UUDD",
            date: date(day: 26, hour: 11, minute: 00),
            wind: Wind(direction: 250, speed: Wind.Speed(value: 7, unit: .metersPerSecond), gustSpeed: nil, variation: Wind.Variation(from: 200, to: 290)),
            qnh: QNH(value: 997, unit: .hectopascals),
            cloudLayers: [CloudLayer(coverage: .broken, height: .init(value: 2600, unit: .feet))],
            visibility: Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true),
            trends: [Forecast(metarRepresentation: METAR(identifier: "UUDD", date: date(day: 26, hour: 11, minute: 00), wind: Wind(direction: 280, speed: Wind.Speed(value: 12, unit: .metersPerSecond), gustSpeed: Wind.Speed(value: 18, unit: .metersPerSecond), variation: nil), cloudLayers: [CloudLayer(coverage: .broken, height: CloudLayer.Height(value: 1500, unit: .feet), significantCloudType: .cumulonimbus)], visibility: Visibility(value: 1500, unit: .meters), weather: [Weather(modifier: .moderate, phenomena: [.thunderstorm, .rain])], metarString: "28012G18MPS 1500 TSRA BKN015CB", flightRules: .mvfr), type: .temporaryForecast)],
            temperature: Temperature(value: 14, unit: .celsius),
            dewPoint: Temperature(value: 8, unit: .celsius),
            remarks: "TEST REMARKS",
            metarString: metarString,
            flightRules: .mvfr
        )

        try XCTAssertEqual(XCTUnwrap(metar), XCTUnwrap(testMETAR))
    }

    func testLIFRVisibility() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 1/8SM")).flightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 1/4SM")).flightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 1/2SM")).flightRules, .lifr)
        try XCTAssertNotEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 1SM")).flightRules, .lifr)
    }

    func testLIFRCeiling() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC001 10SM")).flightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC002 10SM")).flightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC003 10SM")).flightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC004 10SM")).flightRules, .lifr)
        try XCTAssertNotEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC005 10SM")).flightRules, .lifr)
    }

    func testIFRVisibility() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 1SM")).flightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 2SM")).flightRules, .ifr)
        try XCTAssertNotEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 3SM")).flightRules, .ifr)
    }

    func testIFRCeiling() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC005 10SM")).flightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC009 10SM")).flightRules, .ifr)
        try XCTAssertNotEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC010 10SM")).flightRules, .ifr)
    }

    func testMVFRVisibility() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 3SM")).flightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 4SM")).flightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 5SM")).flightRules, .mvfr)
        try XCTAssertNotEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z FEW010 5 1/8SM")).flightRules, .mvfr)
    }

    func testMVFRCeiling() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC010 10SM")).flightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC020 10SM")).flightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC030 10SM")).flightRules, .mvfr)
        try XCTAssertNotEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z OVC031 10SM")).flightRules, .mvfr)
    }

    func testVFR() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).flightRules, .vfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 10SM")).flightRules, .vfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z CAVOK")).flightRules, .vfr)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z SCT010 9999")).flightRules, .vfr)
        try XCTAssertNil(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z ///010 10SM")).flightRules)
    }

    func testWind() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 33008G15KT 300V360")).wind, Wind(direction: 330, speed: Wind.Speed(value: 8, unit: .knots), gustSpeed: Wind.Speed(value: 15, unit: .knots), variation: Wind.Variation(from: 300, to: 360)))
    }

    func testVisbility() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).visibility, Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 10SM")).visibility, Visibility(value: 10, unit: .miles, greaterThanOrEqual: false))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 1 1/8SM")).visibility, Visibility(value: 1.125, unit: .miles, greaterThanOrEqual: false))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 9999")).visibility, Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true))
        try XCTAssertNil(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z CAVOK")).visibility)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z CAVOK")).ceilingAndVisibilityOK, true)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).ceilingAndVisibilityOK, false)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 10SM")).ceilingAndVisibilityOK, false)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 9999")).ceilingAndVisibilityOK, false)
    }

    private func compareMETAR(_ rawMETAR: String, _ identifier: String, _ day: Int, _ hour: Int, _ minute: Int, wind: Wind? = nil, qnh: QNH? = nil, skyCondition: SkyCondition? = nil, cloudLayers: [CloudLayer] = [], visibility: Visibility? = nil, weather: [Weather] = [], trends: [Forecast] = [], militaryColourCode: MilitaryColourCode? = nil, temperature: Temperature? = nil, dewPoint: Temperature? = nil, ceilingAndVisibilityOK: Bool = false, automaticStation: Bool = false, correction: Bool = false, noSignificantChangesExpected: Bool = false, remarks: String? = nil, flightRules: NOAAFlightRules? = nil) throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: rawMETAR)), XCTUnwrap(METAR(
            identifier: identifier,
            date: date(day: day, hour: hour, minute: minute),
            wind: wind,
            qnh: qnh,
            skyCondition: skyCondition,
            cloudLayers: cloudLayers,
            visibility: visibility,
            weather: weather,
            trends: trends,
            militaryColourCode: militaryColourCode,
            temperature: temperature,
            dewPoint: dewPoint,
            ceilingAndVisibilityOK: ceilingAndVisibilityOK,
            automaticStation: automaticStation,
            correction: correction,
            noSignificantChangesExpected: noSignificantChangesExpected,
            remarks: remarks,
            metarString: rawMETAR,
            flightRules: flightRules
        )))
    }

    private func date(day: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: Date())
        if let dateDay = components.day, dateDay < day, let month = components.month {
            components.month = month - 1
        }
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.nanosecond = 0
        return components.date!
    }

}
