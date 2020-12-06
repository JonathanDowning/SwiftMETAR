import XCTest
@testable import METAR

final class METARTests: XCTestCase {

    func testValidMETARs() throws {
        try compareMETAR("KRDU COR 281151Z AUTO 22007KT 9SM SCT040TCU FEW080 FEW250 22/20 SHRA BLU A3004 NOSIG RMK AO2 SLP166 60000 T02170200 10222 20206 53022", "KRDU", 28, 11, 51, wind: Wind(direction: .direction(.init(value: 220, unit: .degrees)), speed: .init(value: 7, unit: .knots)), qnh: .init(value: 30.04, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .scattered, height: .init(value: 4000, unit: .feet), significantCloudType: .toweringCumulus), .init(coverage: .few, height: .init(value: 8000, unit: .feet)), .init(coverage: .few, height: .init(value: 25000, unit: .feet))], visibility: .init(measurement: .init(value: 9, unit: .miles)), weather: [Weather(phenomena: [.showers, .rain])], militaryColorCode: .blue, temperature: 22, dewPoint: 20, automaticStation: true, correction: true, noSignificantChangesExpected: true, remarks: "AO2 SLP166 60000 T02170200 10222 20206 53022", noaaFlightRules: .vfr)
        try compareMETAR("EGGD 121212Z ///010 10SM", "EGGD", 12, 12, 12, cloudLayers: [.init(coverage: .notReported, height: .init(value: 1000, unit: .feet))], visibility: .init(measurement: .init(value: 10, unit: .miles)), noaaFlightRules: .vfr)
        try compareMETAR("PGUA 160631Z 33024G55KT 0SM +RA VV000 23/22 A2891 RESHRA RMK WR//=", "PGUA", 16, 6, 31, wind: Wind(direction: .direction(.init(value: 330, unit: .degrees)), speed: .init(value: 24, unit: .knots), gustSpeed: .init(value: 55, unit: .knots)), qnh: .init(value: 28.91, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 0, unit: .feet))], visibility: .init(measurement: .init(value: 0, unit: .miles)), weather: [.init(modifier: .heavy, phenomena: [.rain]), .init(modifier: .recent, phenomena: [.showers, .rain])], temperature: 23, dewPoint: 22, remarks: "WR//=", noaaFlightRules: .lifr)
        try compareMETAR("EGGD 251250Z AUTO 25016G27KT 220V280 9999 BKN019///TCU 11/11 VCFG Q1013", "EGGD", 25, 12, 50, wind: Wind(direction: .direction(.init(value: 250, unit: .degrees)), speed: .init(value: 16, unit: .knots), gustSpeed: .init(value: 27, unit: .knots), variation: .init(from: .init(value: 220, unit: .degrees), to: .init(value: 280, unit: .degrees))),qnh: .init(value: 1013, unit: .hectopascals), cloudLayers: [.init(coverage: .broken, height: .init(value: 1900, unit: .feet), significantCloudType: .toweringCumulus)], visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), weather: [.init(modifier: .inTheVicinity, phenomena: [.fog])], temperature: 11, dewPoint: 11, automaticStation: true, noaaFlightRules: .mvfr)
        try compareMETAR("UUDD 261100Z 25007MPS 200V290 9999 BKN026 14/08 Q0997 R88/290095 TEMPO 28012G18MPS 1500 TSRA BKN015CB RMK TEST REMARKS", "UUDD", 26, 11, 0, wind: Wind(direction: .direction(.init(value: 250, unit: .degrees)), speed: .init(value: 7, unit: .metersPerSecond), variation: .init(from: .init(value: 200, unit: .degrees), to: .init(value: 290, unit: .degrees))), qnh: .init(value: 997, unit: .hectopascals), cloudLayers: [CloudLayer(coverage: .broken, height: .init(value: 2600, unit: .feet))], visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), conditons: [.init(runwayDesignation: .allRunways, reportType: .default(.wetOrWaterPatches, .high, .minimal, .good))], trends: [.init(metarRepresentation: .init(identifier: "UUDD", wind: .init(direction: .direction(.init(value: 280, unit: .degrees)), speed: .init(value: 12, unit: .metersPerSecond), gustSpeed: .init(value: 18, unit: .metersPerSecond)), cloudLayers: [.init(coverage: .broken, height: .init(value: 1500, unit: .feet), significantCloudType: .cumulonimbus)], visibility: .init(measurement: .init(value: 1500, unit: .meters)), weather: [.init(modifier: .moderate, phenomena: [.thunderstorm, .rain])], noaaFlightRules: .lifr), type: .temporaryForecast)], temperature: 14, dewPoint: 8, remarks: "TEST REMARKS", noaaFlightRules: .mvfr)
        try compareMETAR("KBLD 061212Z AUTO 36004KT 1/4SM R18L/1600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 360, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18L", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18R/1600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18C/1600FT RA OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18C", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.rain])], temperature: 25, dewPoint: 25, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18/1600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18R/M0600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(modifier: .lessThan, measurement: .init(value: 600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18R/P1000 FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(modifier: .greaterThan, measurement: .init(value: 1000, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0700V1000FT FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 700, unit: .feet)), variableVisibility: .init(measurement: .init(value: 1000, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400 FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400U FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)), trend: .increasing)], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400 FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400D R22/M0300N FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)), trend: .decreasing), .init(runway: "22", visibility: .init(modifier: .lessThan, measurement: .init(value: 300, unit: .meters)), trend: .notChanging)], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("LRTC 032130Z AUTO 26003KT 230V300 1000 R34/0900V1400U FG SCT001 BKN042 02/02 Q1022", "LRTC", 3, 21, 30, wind: .init(direction: .direction(.init(value: 260, unit: .degrees)), speed: .init(value: 3, unit: .knots), variation: .init(from: .init(value: 230, unit: .degrees), to: .init(value: 300, unit: .degrees))), qnh: .init(value: 1022, unit: .hectopascals), cloudLayers: [.init(coverage: .scattered, height: .init(value: 100, unit: .feet)), .init(coverage: .broken, height: .init(value: 4200, unit: .feet))], visibility: .init(measurement: .init(value: 1000, unit: .meters)), rvrs: [.init(runway: "34", visibility: .init(measurement: .init(value: 900, unit: .meters)), variableVisibility: .init(measurement: .init(value: 1400, unit: .meters)), trend: .increasing)], weather: [.init(phenomena: [.fog])], temperature: 2, dewPoint: 2, automaticStation: true, noaaFlightRules: .lifr)
        try compareMETAR("VIAR 032130Z 00000KT 0500 R34/1000 FG NSC 12/11 Q1013", "VIAR", 3, 21, 30, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 1013, unit: .hectopascals), skyCondition: .noSignificantCloud, visibility: .init(measurement: .init(value: 500, unit: .meters)), rvrs: [.init(runway: "34", visibility: .init(measurement: .init(value: 1000, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 12, dewPoint: 11, noaaFlightRules: .lifr)
        try compareMETAR("ROIG 040300Z 02022KT 5000 R04/1300VP2000N SHRA FEW007 SCT011 BKN019 19/19 Q1017", "ROIG", 4, 3, 0, wind: .init(direction: .direction(.init(value: 20, unit: .degrees)), speed: .init(value: 22, unit: .knots)), qnh: .init(value: 1017, unit: .hectopascals), cloudLayers: [.init(coverage: .few, height: .init(value: 700, unit: .feet)), .init(coverage: .scattered, height: .init(value: 1100, unit: .feet)), .init(coverage: .broken, height: .init(value: 1900, unit: .feet))], visibility: .init(measurement: .init(value: 5000, unit: .meters)), rvrs: [.init(runway: "04", visibility: .init(measurement: .init(value: 1300, unit: .meters)), variableVisibility: .init(modifier: .greaterThan, measurement: .init(value: 2000, unit: .meters)), trend: .notChanging)], weather: [.init(phenomena: [.showers, .rain])], temperature: 19, dewPoint: 19, noaaFlightRules: .mvfr)
        try compareMETAR("KACV 040308Z AUTO 16004KT 1SM R32/1400VP6000FT BR VV003 07/06 A3034 RMK AO2 T00670056", "KACV", 4, 3, 8, wind: .init(direction: .direction(.init(value: 160, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 30.34, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 1, unit: .miles)), rvrs: [.init(runway: "32", visibility: .init(measurement: .init(value: 1400, unit: .feet)), variableVisibility: .init(modifier: .greaterThan, measurement: .init(value: 6000, unit: .feet)))], weather: [.init(phenomena: [.mist])], temperature: 7, dewPoint: 6, automaticStation: true, remarks: "AO2 T00670056", noaaFlightRules: .lifr)
        try compareMETAR("KACV 040308Z AUTO 16004KT 1SM R32/1400VP6000FTU BR VV003 07/06 A3034 RMK AO2 T00670056", "KACV", 4, 3, 8, wind: .init(direction: .direction(.init(value: 160, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 30.34, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 1, unit: .miles)), rvrs: [.init(runway: "32", visibility: .init(measurement: .init(value: 1400, unit: .feet)), variableVisibility: .init(modifier: .greaterThan, measurement: .init(value: 6000, unit: .feet)), trend: .increasing)], weather: [.init(phenomena: [.mist])], temperature: 7, dewPoint: 6, automaticStation: true, remarks: "AO2 T00670056", noaaFlightRules: .lifr)
        try compareMETAR("KACV 040308Z AUTO 16004KT 1SMR32/1400VP6000FT BR VV003 07/06 A3034 RMK AO2 T00670056", "KACV", 4, 3, 8, wind: .init(direction: .direction(.init(value: 160, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 30.34, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 300, unit: .feet))], weather: [.init(phenomena: [.mist])], temperature: 7, dewPoint: 6, automaticStation: true, remarks: "AO2 T00670056", noaaFlightRules: .lifr)
        try compareMETAR("VOCI 041130Z 03007KT 5000 HZ FEW015 BKN080 30/22 Q1005 NOSIG", "VOCI", 4, 11, 30, wind: .init(direction: .direction(.init(value: 30, unit: .degrees)), speed: .init(value: 7, unit: .knots)), qnh: .init(value: 1005, unit: .hectopascals), cloudLayers: [.init(coverage: .few, height: .init(value: 1500, unit: .feet)), .init(coverage: .broken, height: .init(value: 8000, unit: .feet))], visibility: .init(measurement: .init(value: 5000, unit: .meters)), weather: [.init(phenomena: [.haze])], temperature: 30, dewPoint: 22, noSignificantChangesExpected: true, noaaFlightRules: .mvfr)
        try compareMETAR("K1S5 041235Z AUTO 00000KT M1/4SM FZFG OVC002 M04/M04 A3058 RMK AO2 T10411044", "K1S5", 4, 12, 35, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 30.58, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 200, unit: .feet))], visibility: .init(modifier: .lessThan, measurement: .init(value: 0.25, unit: .miles)), weather: [.init(phenomena: [.freezing, .fog])], temperature: -4, dewPoint: -4, automaticStation: true, remarks: "AO2 T10411044", noaaFlightRules: .lifr)
        try compareMETAR("K1S5 041235Z AUTO 00000KT M1 1/4SM FZFG OVC002 M04/M04 A3058 RMK AO2 T10411044", "K1S5", 4, 12, 35, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 30.58, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 200, unit: .feet))], visibility: .init(modifier: .lessThan, measurement: .init(value: 1.25, unit: .miles)), weather: [.init(phenomena: [.freezing, .fog])], temperature: -4, dewPoint: -4, automaticStation: true, remarks: "AO2 T10411044", noaaFlightRules: .lifr)
        try compareMETAR("K1S5 041235Z AUTO 00000KT M4SM FZFG OVC002 M04/M04 A3058 RMK AO2 T10411044", "K1S5", 4, 12, 35, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 30.58, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 200, unit: .feet))], visibility: .init(modifier: .lessThan, measurement: .init(value: 4, unit: .miles)), weather: [.init(phenomena: [.freezing, .fog])], temperature: -4, dewPoint: -4, automaticStation: true, remarks: "AO2 T10411044", noaaFlightRules: .lifr)
        try compareMETAR("CYRB 041300Z 11026G34KT 3/8SM R35/5000V6000FT/U IC BLSN OVC005 M19/M22 A2984 RMK BLSN3ST8 PRESFR SLP118", "CYRB", 4, 13, 0, wind: .init(direction: .direction(.init(value: 110, unit: .degrees)), speed: .init(value: 26, unit: .knots), gustSpeed: .init(value: 34, unit: .knots)), qnh: .init(value: 29.84, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 500, unit: .feet))], visibility: .init(measurement: .init(value: 0.375, unit: .miles)), rvrs: [.init(runway: "35", visibility: .init(measurement: .init(value: 5000, unit: .feet)), variableVisibility: .init(measurement: .init(value: 6000, unit: .feet)), trend: .increasing)], weather: [.init(phenomena: [.iceCrystals]), .init(phenomena: [.blowing, .snow])], temperature: -19, dewPoint: -22, remarks: "BLSN3ST8 PRESFR SLP118", noaaFlightRules: .lifr)
        try compareMETAR("EGXW 041250Z 26012KT 9999 5000SE -RADZ OVC003 01/00 Q0970 TEMPO 2000 -SN RMK BLACKYLO2 TEMPO YLO2", "EGXW", 4, 12, 50, wind: .init(direction: .direction(.init(value: 260, unit: .degrees)), speed: .init(value: 12, unit: .knots)), qnh: .init(value: 970, unit: .hectopascals), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), directionalVisibilities: [.init(visibility: .init(measurement: .init(value: 5000, unit: .meters)), direction: .southEast)], weather: [.init(modifier: .light, phenomena: [.rain, .drizzle])], trends: [.init(metarRepresentation: .init(identifier: "EGXW", visibility: .init(measurement: .init(value: 2000, unit: .meters)), weather: [.init(modifier: .light, phenomena: [.snow])], noaaFlightRules: .ifr), type: .temporaryForecast)], temperature: 1, dewPoint: 0, remarks: "BLACKYLO2 TEMPO YLO2", noaaFlightRules: .lifr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 Q1008", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 1008, unit: .hectopascals), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, noaaFlightRules: .vfr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 A2992 Q1013", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 29.92, unit: .inchesOfMercury), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, noaaFlightRules: .vfr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 Q1013 A2992", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 29.92, unit: .inchesOfMercury), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, noaaFlightRules: .vfr)
        try compareMETAR("EGGD 041350Z 18018KT 8000 6000W 3000NE 02/M02 Q1013", "EGGD", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 1013, unit: .hectopascals), visibility: .init(measurement: .init(value: 8000, unit: .meters)), directionalVisibilities: [.init(visibility: .init(measurement: .init(value: 6000, unit: .meters)), direction: .west), .init(visibility: .init(measurement: .init(value: 3000, unit: .meters)), direction: .northEast)], temperature: 2, dewPoint: -2, noaaFlightRules: .mvfr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 Q1013 A2992 A2991", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 29.92, unit: .inchesOfMercury), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, noaaFlightRules: .vfr)
        try compareMETAR("ENHF 041850Z VRB01KT CAVOK M00/M04 Q1007 RMK WIND 1254FT 18006KT", "ENHF", 4, 18, 50, wind: .init(direction: .variable, speed: .init(value: 1, unit: .knots)), qnh: .init(value: 1007, unit: .hectopascals), temperature: -0, dewPoint: -4, ceilingAndVisibilityOK: true, remarks: "WIND 1254FT 18006KT", noaaFlightRules: .vfr)
        try compareMETAR("KMWN 051957Z 03039G44KT 1/16SM -SN FZFG BLSN VV001 M08/M08 RMK PRESFR VRY LGT ICG", "KMWN", 5, 19, 57, wind: .init(direction: .direction(.init(value: 30, unit: .degrees)), speed: .init(value: 39, unit: .knots), gustSpeed: .init(value: 44, unit: .knots)), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 100, unit: .feet))], visibility: .init(measurement: .init(value: 1/16, unit: .miles)), weather: [.init(modifier: .light, phenomena: [.snow]), .init(phenomena: [.freezing, .fog]), .init(phenomena: [.blowing, .snow])], temperature: -8, dewPoint: -8, remarks: "PRESFR VRY LGT ICG", noaaFlightRules: .lifr)
        try compareMETAR("LOXZ 052050Z VRB03KT 10KM FEW030SC SCT050SC BKN270CI 03/02 Q1006", "LOXZ", 5, 20, 50, wind: .init(direction: .variable, speed: .init(value: 3, unit: .knots)), qnh: .init(value: 1006, unit: .hectopascals), cloudLayers: [.init(coverage: .few, height: .init(value: 3000, unit: .feet)), .init(coverage: .scattered, height: .init(value: 5000, unit: .feet)), .init(coverage: .broken, height: .init(value: 27000, unit: .feet))], visibility: .init(measurement: .init(value: 10, unit: .kilometers)), temperature: 3, dewPoint: 2, noaaFlightRules: .vfr)
        try compareMETAR("SVBS 052102Z AUTO 21005KT NCD 30/// Q1014", "SVBS", 5, 21, 2, wind: .init(direction: .direction(.init(value: 210, unit: .degrees)), speed: .init(value: 5, unit: .knots)), qnh: .init(value: 1014, unit: .hectopascals), skyCondition: .noCloudDetected, temperature: 30, automaticStation: true, noaaFlightRules: .vfr)
        try compareMETAR("UCFO 052130Z VRB01MPS 1300 1200N R12/P1500N BR NSC M03/M03 Q1027 R12/0///95 NOSIG", "UCFO", 5, 21, 30, wind: .init(direction: .variable, speed: .init(value: 1, unit: .metersPerSecond)), qnh: .init(value: 1027, unit: .hectopascals), skyCondition: .noSignificantCloud, visibility: .init(measurement: .init(value: 1300, unit: .meters)), directionalVisibilities: [.init(visibility: .init(measurement: .init(value: 1200, unit: .meters)), direction: .north)], conditons: [.init(runwayDesignation: .runway("12"), reportType: .default(.clearAndDry, .notReported, .depthNotSignificant, .good))], rvrs: [.init(runway: "12", visibility: .init(modifier: .greaterThan, measurement: .init(value: 1500, unit: .meters)), trend: .notChanging)], weather: [.init(phenomena: [.mist])], temperature: -3, dewPoint: -3, noSignificantChangesExpected: true, noaaFlightRules: .lifr)
        try compareMETAR("URMN 060300Z 03001MPS 2000 -SG BR OVC004 M03/M04 Q1027 R24/////// NOSIG RMK MT OBSC OBST OBSC QFE734", "URMN", 6, 3, 0, wind: .init(direction: .direction(.init(value: 30, unit: .degrees)), speed: .init(value: 1, unit: .metersPerSecond)), qnh: .init(value: 1027, unit: .hectopascals), cloudLayers: [.init(coverage: .overcast, height: .init(value: 400, unit: .feet))], visibility: .init(measurement: .init(value: 2000, unit: .meters)), conditons: [.init(runwayDesignation: .runway("24"), reportType: .reportNotUpdated)], weather: [.init(modifier: .light, phenomena: [.snowGrains]), .init(phenomena: [.mist])], temperature: -3, dewPoint: -4, noSignificantChangesExpected: true, remarks: "MT OBSC OBST OBSC QFE734", noaaFlightRules: .lifr)
        try compareMETAR("UTSK 060400Z VRB02KT CAVOK 01/M09 Q1029 R16/CLRD70", "UTSK", 6, 4, 0, wind: .init(direction: .variable, speed: .init(value: 2, unit: .knots)), qnh: .init(value: 1029, unit: .hectopascals), conditons: [.init(runwayDesignation: .runway("16"), reportType: .contaiminationDisappeared(.frictionCoefficient(0.7)))], temperature: 1, dewPoint: -9, ceilingAndVisibilityOK: true, noaaFlightRules: .vfr)
        try compareMETAR("CYWL 060400Z 14020G//KT 15SM SKC 03/M06 A2994 RMK WND ESTD SLP172", "CYWL", 6, 4, 0, wind: .init(direction: .direction(.init(value: 140, unit: .degrees)), speed: .init(value: 20, unit: .knots)), qnh: .init(value: 29.94, unit: .inchesOfMercury), skyCondition: .skyClear, visibility: .init(measurement: .init(value: 15, unit: .miles)), temperature: 3, dewPoint: -6, remarks: "WND ESTD SLP172", noaaFlightRules: .vfr)
        try compareMETAR("CWJB 061800Z AUTO 32007KT M03/ RMK AO1 SOG 13 PK WND 32017/1717 T1034", "CWJB", 6, 18, 0, wind: .init(direction: .direction(.init(value: 320, unit: .degrees)), speed: .init(value: 7, unit: .knots)), temperature: -3, automaticStation: true, remarks: "AO1 SOG 13 PK WND 32017/1717 T1034")
        try compareMETAR("UBBN 061800Z 10006KT 8000 BKN043 03/M01 Q1020 R14R/CLRD// NOSIG RMK MT OBSC QFE690", "UBBN", 6, 18, 0, wind: .init(direction: .direction(.init(value: 100, unit: .degrees)), speed: .init(value: 6, unit: .knots)), qnh: .init(value: 1020, unit: .hectopascals), cloudLayers: [.init(coverage: .broken, height: .init(value: 4300, unit: .feet))], visibility: .init(measurement: .init(value: 8000, unit: .meters)), conditons: [.init(runwayDesignation: .runway("14R"), reportType: .contaiminationDisappeared(.notReported))], temperature: 3, dewPoint: -1, noSignificantChangesExpected: true, remarks: "MT OBSC QFE690", noaaFlightRules: .mvfr)
    }

    func testInvalidMETARs() {
        XCTAssertNil(METAR("KRDU 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
        XCTAssertNil(METAR("012345Z 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
        XCTAssertNil(METAR("RDU 012345Z 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
        XCTAssertNil(METAR("KRDU 12345Z 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
        XCTAssertNil(METAR("KRDU 0123456Z 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
        XCTAssertNil(METAR("KRDU 012345 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
    }

    func testNOAAFlightRules() throws {
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z OVC004")).noaaFlightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z OVC005")).noaaFlightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z OVC010")).noaaFlightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z OVC030")).noaaFlightRules, .mvfr)
        try XCTAssertNil(XCTUnwrap(METAR("ABCD 012345Z OVC031")).noaaFlightRules)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 1/2SM")).noaaFlightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 1SM")).noaaFlightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 3SM")).noaaFlightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 6SM")).noaaFlightRules, .vfr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 1SM CAVOK")).noaaFlightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z CAVOK")).noaaFlightRules, .vfr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 10SM OVC004")).noaaFlightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 1/2SM FEW100")).noaaFlightRules, .lifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 10SM OVC005")).noaaFlightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 1SM FEW100")).noaaFlightRules, .ifr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 10SM OVC010")).noaaFlightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 3SM FEW100")).noaaFlightRules, .mvfr)
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z 6SM FEW100")).noaaFlightRules, .vfr)
    }

    func testWindGusts() throws {
        try XCTAssertNil(XCTUnwrap(METAR("EGGD 121212Z 18010KT")).wind?.gustSpeed)
        try XCTAssertNil(XCTUnwrap(METAR("EGGD 121212Z 18010G//KT")).wind?.gustSpeed)
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 18010G20KT")).wind?.gustSpeed, .init(value: 20, unit: .knots))
    }

    func testWind() throws {
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 33008G15KT 300V360")).wind, .init(direction: .direction(.init(value: 330, unit: .degrees)), speed: .init(value: 8, unit: .knots), gustSpeed: .init(value: 15, unit: .knots), variation: .init(from: .init(value: 300, unit: .degrees), to: .init(value: 360, unit: .degrees))))
    }

    func testVisbility() throws {
        try XCTAssertEqual(XCTUnwrap(METAR("EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).visibility, .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)))
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 10SM")).visibility, .init(measurement: .init(value: 10, unit: .miles)))
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 10SM")).visibility, .init(measurement: .init(value: 10, unit: .miles)))
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 1 1/8SM")).visibility, .init(measurement: .init(value: 1.125, unit: .miles)))
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 9999")).visibility, .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)))
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z P5SM")).visibility, .init(modifier: .greaterThan, measurement: .init(value: 5, unit: .miles)))
        try XCTAssertNil(XCTUnwrap(METAR("EGGD 121212Z CAVOK")).visibility)
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z CAVOK")).isCeilingAndVisibilityOK, true)
        try XCTAssertEqual(XCTUnwrap(METAR("EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).isCeilingAndVisibilityOK, false)
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 10SM")).isCeilingAndVisibilityOK, false)
        try XCTAssertEqual(XCTUnwrap(METAR("EGGD 121212Z 9999")).isCeilingAndVisibilityOK, false)
    }

    func testCeilings() throws {
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z OVC001 BKN002 FEW003")).ceiling, .init(value: 100, unit: .feet))
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z BKN011 FEW010 OVC012")).ceiling, .init(value: 1100, unit: .feet))
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z FEW005")).ceiling, .init(value: .greatestFiniteMagnitude, unit: .feet))
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z")).ceiling, .init(value: .greatestFiniteMagnitude, unit: .feet))
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z VV010 BKN011")).ceiling, .init(value: 1000, unit: .feet))
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z ///010")).ceiling, .init(value: .greatestFiniteMagnitude, unit: .feet))
        try XCTAssertEqual(XCTUnwrap(METAR("ABCD 012345Z OVC///")).ceiling, .init(value: .greatestFiniteMagnitude, unit: .feet))
    }

    private func compareMETAR(_ rawMETAR: String, _ identifier: String, _ day: Int, _ hour: Int, _ minute: Int, wind: Wind? = nil, qnh: Measurement<UnitPressure>? = nil, skyCondition: SkyCondition? = nil, cloudLayers: [CloudLayer] = [], visibility: Visibility? = nil, directionalVisibilities: [DirectionalVisibility] = [], conditons: [RunwayCondition] = [], rvrs: [RunwayVisualRange] = [], weather: [Weather] = [], trends: [Trend] = [], militaryColorCode: MilitaryColorCode? = nil, temperature: Double? = nil, dewPoint: Double? = nil, ceilingAndVisibilityOK: Bool = false, automaticStation: Bool = false, correction: Bool = false, noSignificantChangesExpected: Bool = false, remarks: String? = nil, noaaFlightRules: NOAAFlightRules? = nil) throws {
        let metar = try XCTUnwrap(METAR(rawMETAR))
        XCTAssertEqual(metar.identifier, identifier)
        XCTAssertEqual(metar.dateComponents, DateComponents(timeZone: TimeZone(identifier: "UTC"), day: day, hour: hour, minute: minute))
        XCTAssertEqual(metar.wind, wind)
        XCTAssertEqual(metar.skyCondition, skyCondition)
        XCTAssertEqual(metar.cloudLayers, cloudLayers)
        XCTAssertEqual(metar.visibility, visibility)
        XCTAssertEqual(metar.directionalVisibilities, directionalVisibilities)
        XCTAssertEqual(metar.runwayConditions, conditons)
        XCTAssertEqual(metar.runwayVisualRanges, rvrs)
        XCTAssertEqual(metar.weather, weather)
        XCTAssertEqual(metar.temperature, temperature.map { .init(value: $0, unit: .celsius) })
        XCTAssertEqual(metar.dewPoint, dewPoint.map { .init(value: $0, unit: .celsius) })
        XCTAssertEqual(metar.qnh, qnh)
        XCTAssertEqual(metar.trends, trends)
        XCTAssertEqual(metar.militaryColorCode, militaryColorCode)
        XCTAssertEqual(metar.isCeilingAndVisibilityOK, ceilingAndVisibilityOK)
        XCTAssertEqual(metar.isAutomatic, automaticStation)
        XCTAssertEqual(metar.isCorrection, correction)
        XCTAssertEqual(metar.noSignificantChangesExpected, noSignificantChangesExpected)
        XCTAssertEqual(metar.remarks, remarks)
        XCTAssertEqual(metar.noaaFlightRules, noaaFlightRules)
    }

}
