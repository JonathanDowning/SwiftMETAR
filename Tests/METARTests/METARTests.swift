import XCTest
@testable import METAR

class METARTests: XCTestCase {
    
    func testDatelessMETAR() {
        let metarString = "KRDU 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"
        let metar = METAR(rawMETAR: metarString)
        XCTAssertNil(metar)
    }
    
    func testSimpleMETAR() {
        let metarString = "KRDU COR 281151Z AUTO 22007KT 9SM SCT040TCU FEW080 FEW250 22/20 SHRA BLU A3004 NOSIG RMK AO2 SLP166 60000 T02170200 10222 20206 53022"
        let metar = METAR(rawMETAR: metarString)
        let testMETAR = METAR(
            identifier: "KRDU",
            date: date(day: 28, hour: 11, minute: 51),
            wind: Wind(direction: 220, speed: Wind.Speed(value: 7, unit: .knots), gustSpeed: nil, variation: nil),
            qnh: QNH(value: 30.04, unit: .inchesOfMercury),
            skyCondition: nil,
            cloudLayers: [CloudLayer(coverage: .scattered, height: CloudLayer.Height(value: 4000, unit: .feet), significantCloudType: .toweringCumulus), CloudLayer(coverage: .few, height: CloudLayer.Height(value: 8000, unit: .feet), significantCloudType: nil), CloudLayer(coverage: .few, height: CloudLayer.Height(value: 25000, unit: .feet), significantCloudType: nil)],
            visibility: Visibility(value: 9, unit: .miles, greaterThanOrEqual: false),
            weather: [Weather(modifier: .moderate, phenomena: [.showers, .rain])],
            trends: [],
            militaryColourCode: .blue,
            temperature: Temperature(value: 22, unit: .celsius),
            dewPoint: Temperature(value: 20, unit: .celsius),
            relativeHumidity: 0.88436416127981798,
            ceilingAndVisibilityOK: false,
            automaticStation: true,
            correction: true,
            noSignificantChangesExpected: true,
            remarks: "AO2 SLP166 60000 T02170200 10222 20206 53022",
            metarString: metarString,
            flightRules: .vfr
        )
        
        XCTAssertEqual(metar, testMETAR)
    }
    
    func testSlashesInBetweenCloudTypeAndHeight() {
        let metarString = "EGGD 251250Z AUTO 25016G27KT 220V280 9999 BKN019///TCU 11/11 Q1013"
        let metar = METAR(rawMETAR: metarString)
        let testMETAR = METAR(
            identifier: "EGGD",
            date: date(day: 25, hour: 12, minute: 50),
            wind: Wind(direction: 250, speed: Wind.Speed(value: 16, unit: .knots), gustSpeed: Wind.Speed(value: 27, unit: .knots), variation: Wind.Variation(from: 220, to: 280)),
            qnh: QNH(value: 1013, unit: .hectopascals),
            skyCondition: nil,
            cloudLayers: [CloudLayer(coverage: .broken, height: CloudLayer.Height(value: 1900, unit: .feet), significantCloudType: .toweringCumulus)],
            visibility: Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true),
            weather: [],
            trends: [],
            militaryColourCode: nil,
            temperature: Temperature(value: 11, unit: .celsius),
            dewPoint: Temperature(value: 11, unit: .celsius),
            relativeHumidity: 1,
            ceilingAndVisibilityOK: false,
            automaticStation: true,
            correction: false,
            noSignificantChangesExpected: false,
            remarks: nil,
            metarString: metarString,
            flightRules: .mvfr
        )
        
        XCTAssertEqual(metar, testMETAR)
    }
    
    func testTEMPO() {
        let metarString = "UUDD 261100Z 25007MPS 200V290 9999 BKN026 14/08 Q0997 R88/290095 TEMPO 28012G18MPS 1500 TSRA BKN015CB RMK TEST REMARKS"
        let metar = METAR(rawMETAR: metarString)
        let testMETAR = METAR(
            identifier: "UUDD",
            date: date(day: 26, hour: 11, minute: 00),
            wind: Wind(direction: 250, speed: Wind.Speed(value: 7, unit: .metersPerSecond), gustSpeed: nil, variation: Wind.Variation(from: 200, to: 290)),
            qnh: QNH(value: 997, unit: .hectopascals),
            skyCondition: nil,
            cloudLayers: [CloudLayer(coverage: .broken, height: CloudLayer.Height(value: 2600, unit: .feet), significantCloudType: nil)],
            visibility: Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true),
            weather: [],
            trends: [Forecast(metarRepresentation: METAR(identifier: "UUDD", date: date(day: 26, hour: 11, minute: 00), wind: Wind(direction: 280, speed: Wind.Speed(value: 12, unit: .metersPerSecond), gustSpeed: Wind.Speed(value: 18, unit: .metersPerSecond), variation: nil), qnh: nil, skyCondition: nil, cloudLayers: [CloudLayer(coverage: .broken, height: CloudLayer.Height(value: 1500, unit: .feet), significantCloudType: .cumulonimbus)], visibility: Visibility(value: 1500, unit: .meters, greaterThanOrEqual: false), weather: [Weather(modifier: .moderate, phenomena: [.thunderstorm, .rain])], trends: [], militaryColourCode: nil, temperature: nil, dewPoint: nil, relativeHumidity: nil, ceilingAndVisibilityOK: false, automaticStation: false, correction: false, noSignificantChangesExpected: false, remarks: nil, metarString: "28012G18MPS 1500 TSRA BKN015CB", flightRules: .mvfr), type: .temporaryForecast)],
            militaryColourCode: nil,
            temperature: Temperature(value: 14, unit: .celsius),
            dewPoint: Temperature(value: 8, unit: .celsius),
            relativeHumidity: 0.67145798064498396,
            ceilingAndVisibilityOK: false,
            automaticStation: false,
            correction: false,
            noSignificantChangesExpected: false,
            remarks: "TEST REMARKS",
            metarString: metarString,
            flightRules: .mvfr
        )
        XCTAssertEqual(metar, testMETAR)
    }
    
    func testLIFRVisibility() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 1/8SM")?.flightRules, .lifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 1/4SM")?.flightRules, .lifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 1/2SM")?.flightRules, .lifr)
        XCTAssertNotEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 1SM")?.flightRules, .lifr)
    }
    
    func testLIFRCeiling() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC001 10SM")?.flightRules, .lifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC002 10SM")?.flightRules, .lifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC003 10SM")?.flightRules, .lifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC004 10SM")?.flightRules, .lifr)
        XCTAssertNotEqual(METAR(rawMETAR: "EGGD 121212Z OVC005 10SM")?.flightRules, .lifr)
    }
    
    func testIFRVisibility() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 1SM")?.flightRules, .ifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 2SM")?.flightRules, .ifr)
        XCTAssertNotEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 3SM")?.flightRules, .ifr)
    }
    
    func testIFRCeiling() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC005 10SM")?.flightRules, .ifr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC009 10SM")?.flightRules, .ifr)
        XCTAssertNotEqual(METAR(rawMETAR: "EGGD 121212Z OVC010 10SM")?.flightRules, .ifr)
    }
    
    func testMVFRVisibility() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 3SM")?.flightRules, .mvfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 4SM")?.flightRules, .mvfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 5SM")?.flightRules, .mvfr)
        XCTAssertNotEqual(METAR(rawMETAR: "EGGD 121212Z FEW010 5 1/8SM")?.flightRules, .mvfr)
    }
    
    func testMVFRCeiling() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC010 10SM")?.flightRules, .mvfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC020 10SM")?.flightRules, .mvfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z OVC030 10SM")?.flightRules, .mvfr)
        XCTAssertNotEqual(METAR(rawMETAR: "EGGD 121212Z OVC031 10SM")?.flightRules, .mvfr)
    }
    
    func testVFR() {
        XCTAssertEqual(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")?.flightRules, .vfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 10SM")?.flightRules, .vfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z CAVOK")?.flightRules, .vfr)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z SCT010 9999")?.flightRules, .vfr)
        XCTAssertNil(METAR(rawMETAR: "EGGD 121212Z ///010 10SM")?.flightRules)
    }
    
    func testWind() {
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 33008G15KT 300V360")?.wind, Wind(direction: 330, speed: Wind.Speed(value: 8, unit: .knots), gustSpeed: Wind.Speed(value: 15, unit: .knots), variation: Wind.Variation(from: 300, to: 360)))
    }
    
    func testVisbility() {
        XCTAssertEqual(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")?.visibility, Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true))
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 10SM")?.visibility, Visibility(value: 10, unit: .miles, greaterThanOrEqual: false))
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 1 1/8SM")?.visibility, Visibility(value: 1.125, unit: .miles, greaterThanOrEqual: false))
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 9999")?.visibility, Visibility(value: 10, unit: .kilometers, greaterThanOrEqual: true))
        XCTAssertNil(METAR(rawMETAR: "EGGD 121212Z CAVOK")?.visibility)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z CAVOK")?.ceilingAndVisibilityOK, true)
        XCTAssertEqual(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")?.ceilingAndVisibilityOK, false)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 10SM")?.ceilingAndVisibilityOK, false)
        XCTAssertEqual(METAR(rawMETAR: "EGGD 121212Z 9999")?.ceilingAndVisibilityOK, false)
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
    
    static var allTests = [
        ("testDatelessMETAR", testDatelessMETAR),
        ("testSimpleMETAR", testSimpleMETAR),
        ("testLIFRVisibility", testLIFRVisibility),
        ("testLIFRCeiling", testLIFRCeiling),
        ("testIFRVisibility", testIFRVisibility),
        ("testIFRCeiling", testIFRCeiling),
        ("testMVFRVisibility", testMVFRVisibility),
        ("testMVFRCeiling", testMVFRCeiling),
        ("testVFR", testVFR),
        ("testWind", testWind),
        ("testVisbility", testVisbility)
    ]
}
