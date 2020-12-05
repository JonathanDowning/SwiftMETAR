import XCTest
@testable import METAR

final class METARTests: XCTestCase {

    func testValidMETARs() throws {
        try compareMETAR("KRDU COR 281151Z AUTO 22007KT 9SM SCT040TCU FEW080 FEW250 22/20 SHRA BLU A3004 NOSIG RMK AO2 SLP166 60000 T02170200 10222 20206 53022", "KRDU", 28, 11, 51, wind: Wind(direction: .direction(.init(value: 220, unit: .degrees)), speed: .init(value: 7, unit: .knots)), qnh: .init(value: 30.04, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .scattered, height: .init(value: 4000, unit: .feet), significantCloudType: .toweringCumulus), .init(coverage: .few, height: .init(value: 8000, unit: .feet)), .init(coverage: .few, height: .init(value: 25000, unit: .feet))], visibility: .init(measurement: .init(value: 9, unit: .miles)), weather: [Weather(phenomena: [.showers, .rain])], militaryColourCode: .blue, temperature: 22, dewPoint: 20, automaticStation: true, correction: true, noSignificantChangesExpected: true, remarks: "AO2 SLP166 60000 T02170200 10222 20206 53022", flightRules: .vfr)
        try compareMETAR("EGGD 121212Z ///010 10SM", "EGGD", 12, 12, 12, cloudLayers: [.init(coverage: .notReported, height: .init(value: 1000, unit: .feet))], visibility: .init(measurement: .init(value: 10, unit: .miles)), flightRules: nil)
        try compareMETAR("EGGD 121212Z ///010 1 1/4SM", "EGGD", 12, 12, 12, cloudLayers: [.init(coverage: .notReported, height: .init(value: 1000, unit: .feet))], visibility: .init(measurement: .init(value: 1.25, unit: .miles)), flightRules: nil)
        try compareMETAR("EGGD 121212Z ///010/// 1 1/4SM", "EGGD", 12, 12, 12, cloudLayers: [.init(coverage: .notReported, height: .init(value: 1000, unit: .feet))], visibility: .init(measurement: .init(value: 1.25, unit: .miles)), flightRules: nil)
        try compareMETAR("PGUA 160631Z 33024G55KT 0SM +RA VV000 23/22 A2891 RESHRA RMK WR//=", "PGUA", 16, 6, 31, wind: Wind(direction: .direction(.init(value: 330, unit: .degrees)), speed: .init(value: 24, unit: .knots), gustSpeed: .init(value: 55, unit: .knots)), qnh: .init(value: 28.91, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 0, unit: .feet))], visibility: .init(measurement: .init(value: 0, unit: .miles)), weather: [.init(modifier: .heavy, phenomena: [.rain]), .init(modifier: .recent, phenomena: [.showers, .rain])], temperature: 23, dewPoint: 22, remarks: "WR//=", flightRules: .lifr)
        try compareMETAR("EGGD 251250Z AUTO 25016G27KT 220V280 9999 BKN019///TCU 11/11 VCFG Q1013", "EGGD", 25, 12, 50, wind: Wind(direction: .direction(.init(value: 250, unit: .degrees)), speed: .init(value: 16, unit: .knots), gustSpeed: .init(value: 27, unit: .knots), variation: .init(from: .init(value: 220, unit: .degrees), to: .init(value: 280, unit: .degrees))),qnh: .init(value: 1013, unit: .hectopascals), cloudLayers: [.init(coverage: .broken, height: .init(value: 1900, unit: .feet), significantCloudType: .toweringCumulus)], visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), weather: [.init(modifier: .inTheVicinity, phenomena: [.fog])], temperature: 11, dewPoint: 11, automaticStation: true, flightRules: .mvfr)
        try compareMETAR("UUDD 261100Z 25007MPS 200V290 9999 BKN026 14/08 Q0997 R88/290095 TEMPO 28012G18MPS 1500 TSRA BKN015CB RMK TEST REMARKS", "UUDD", 26, 11, 0, wind: Wind(direction: .direction(.init(value: 250, unit: .degrees)), speed: .init(value: 7, unit: .metersPerSecond), variation: .init(from: .init(value: 200, unit: .degrees), to: .init(value: 290, unit: .degrees))), qnh: .init(value: 997, unit: .hectopascals), cloudLayers: [CloudLayer(coverage: .broken, height: .init(value: 2600, unit: .feet))], visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), trends: [.init(metarRepresentation: .init(identifier: "UUDD", date: date(day: 26, hour: 11, minute: 00), wind: .init(direction: .direction(.init(value: 280, unit: .degrees)), speed: .init(value: 12, unit: .metersPerSecond), gustSpeed: .init(value: 18, unit: .metersPerSecond)), cloudLayers: [.init(coverage: .broken, height: .init(value: 1500, unit: .feet), significantCloudType: .cumulonimbus)], visibility: .init(measurement: .init(value: 1500, unit: .meters)), weather: [.init(modifier: .moderate, phenomena: [.thunderstorm, .rain])], metarString: "28012G18MPS 1500 TSRA BKN015CB", flightRules: .lifr), type: .temporaryForecast)], temperature: 14, dewPoint: 8, remarks: "TEST REMARKS", flightRules: .mvfr)
        try compareMETAR("KBLD 061212Z AUTO 36004KT 1/4SM R18L/1600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 360, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18L", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18R/1600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18C/1600FT RA OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18C", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.rain])], temperature: 25, dewPoint: 25, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18/1600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18", visibility: .init(measurement: .init(value: 1600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18R/M0600FT FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(modifier: .lessThan, measurement: .init(value: 600, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00004KT 1/4SM R18R/P1000 FG OVC003 25/25 A2967", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 29.67, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.25, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(modifier: .greaterThan, measurement: .init(value: 1000, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 25, dewPoint: 25, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0700V1000FT FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 700, unit: .feet)), variableVisibility: .init(measurement: .init(value: 1000, unit: .feet)))], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400 FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400U FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)), trend: .increasing)], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400 FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, flightRules: .lifr)
        try compareMETAR("KBLD 061212Z AUTO 00003KT 1/2SM R18R/0400D R22/M0300N FG BKN003 14/14 A3015", "KBLD", 6, 12, 12, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 3, unit: .knots)), qnh: .init(value: 30.15, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .broken, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 0.5, unit: .miles)), rvrs: [.init(runway: "18R", visibility: .init(measurement: .init(value: 400, unit: .meters)), trend: .decreasing), .init(runway: "22", visibility: .init(modifier: .lessThan, measurement: .init(value: 300, unit: .meters)), trend: .notChanging)], weather: [.init(phenomena: [.fog])], temperature: 14, dewPoint: 14, automaticStation: true, flightRules: .lifr)
        try compareMETAR("LRTC 032130Z AUTO 26003KT 230V300 1000 R34/0900V1400U FG SCT001 BKN042 02/02 Q1022", "LRTC", 3, 21, 30, wind: .init(direction: .direction(.init(value: 260, unit: .degrees)), speed: .init(value: 3, unit: .knots), variation: .init(from: .init(value: 230, unit: .degrees), to: .init(value: 300, unit: .degrees))), qnh: .init(value: 1022, unit: .hectopascals), cloudLayers: [.init(coverage: .scattered, height: .init(value: 100, unit: .feet)), .init(coverage: .broken, height: .init(value: 4200, unit: .feet))], visibility: .init(measurement: .init(value: 1000, unit: .meters)), rvrs: [.init(runway: "34", visibility: .init(measurement: .init(value: 900, unit: .meters)), variableVisibility: .init(measurement: .init(value: 1400, unit: .meters)), trend: .increasing)], weather: [.init(phenomena: [.fog])], temperature: 2, dewPoint: 2, automaticStation: true, flightRules: .lifr)
        try compareMETAR("VIAR 032130Z 00000KT 0500 R34/1000 FG NSC 12/11 Q1013", "VIAR", 3, 21, 30, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 1013, unit: .hectopascals), skyCondition: .noSignificantCloud, visibility: .init(measurement: .init(value: 500, unit: .meters)), rvrs: [.init(runway: "34", visibility: .init(measurement: .init(value: 1000, unit: .meters)))], weather: [.init(phenomena: [.fog])], temperature: 12, dewPoint: 11, flightRules: .lifr)
        try compareMETAR("ROIG 040300Z 02022KT 5000 R04/1300VP2000N SHRA FEW007 SCT011 BKN019 19/19 Q1017", "ROIG", 4, 3, 0, wind: .init(direction: .direction(.init(value: 20, unit: .degrees)), speed: .init(value: 22, unit: .knots)), qnh: .init(value: 1017, unit: .hectopascals), cloudLayers: [.init(coverage: .few, height: .init(value: 700, unit: .feet)), .init(coverage: .scattered, height: .init(value: 1100, unit: .feet)), .init(coverage: .broken, height: .init(value: 1900, unit: .feet))], visibility: .init(measurement: .init(value: 5000, unit: .meters)), rvrs: [.init(runway: "04", visibility: .init(measurement: .init(value: 1300, unit: .meters)), variableVisibility: .init(modifier: .greaterThan, measurement: .init(value: 2000, unit: .meters)), trend: .notChanging)], weather: [.init(phenomena: [.showers, .rain])], temperature: 19, dewPoint: 19, flightRules: .mvfr)
        try compareMETAR("KACV 040308Z AUTO 16004KT 1SM R32/1400VP6000FT BR VV003 07/06 A3034 RMK AO2 T00670056", "KACV", 4, 3, 8, wind: .init(direction: .direction(.init(value: 160, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 30.34, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 1, unit: .miles)), rvrs: [.init(runway: "32", visibility: .init(measurement: .init(value: 1400, unit: .feet)), variableVisibility: .init(modifier: .greaterThan, measurement: .init(value: 6000, unit: .feet)))], weather: [.init(phenomena: [.mist])], temperature: 7, dewPoint: 6, automaticStation: true, remarks: "AO2 T00670056", flightRules: .lifr)
        try compareMETAR("KACV 040308Z AUTO 16004KT 1SM R32/1400VP6000FTU BR VV003 07/06 A3034 RMK AO2 T00670056", "KACV", 4, 3, 8, wind: .init(direction: .direction(.init(value: 160, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 30.34, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 300, unit: .feet))], visibility: .init(measurement: .init(value: 1, unit: .miles)), rvrs: [.init(runway: "32", visibility: .init(measurement: .init(value: 1400, unit: .feet)), variableVisibility: .init(modifier: .greaterThan, measurement: .init(value: 6000, unit: .feet)), trend: .increasing)], weather: [.init(phenomena: [.mist])], temperature: 7, dewPoint: 6, automaticStation: true, remarks: "AO2 T00670056", flightRules: .lifr)
        try compareMETAR("KACV 040308Z AUTO 16004KT 1SMR32/1400VP6000FT BR VV003 07/06 A3034 RMK AO2 T00670056", "KACV", 4, 3, 8, wind: .init(direction: .direction(.init(value: 160, unit: .degrees)), speed: .init(value: 4, unit: .knots)), qnh: .init(value: 30.34, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .skyObscured, height: .init(value: 300, unit: .feet))], weather: [.init(phenomena: [.mist])], temperature: 7, dewPoint: 6, automaticStation: true, remarks: "AO2 T00670056", flightRules: .lifr)
        try compareMETAR("VOCI 041130Z 03007KT 5000 HZ FEW015 BKN080 30/22 Q1005 NOSIG", "VOCI", 4, 11, 30, wind: .init(direction: .direction(.init(value: 30, unit: .degrees)), speed: .init(value: 7, unit: .knots)), qnh: .init(value: 1005, unit: .hectopascals), cloudLayers: [.init(coverage: .few, height: .init(value: 1500, unit: .feet)), .init(coverage: .broken, height: .init(value: 8000, unit: .feet))], visibility: .init(measurement: .init(value: 5000, unit: .meters)), weather: [.init(phenomena: [.haze])], temperature: 30, dewPoint: 22, noSignificantChangesExpected: true, flightRules: .mvfr)
        try compareMETAR("K1S5 041235Z AUTO 00000KT M1/4SM FZFG OVC002 M04/M04 A3058 RMK AO2 T10411044", "K1S5", 4, 12, 35, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 30.58, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 200, unit: .feet))], visibility: .init(modifier: .lessThan, measurement: .init(value: 0.25, unit: .miles)), weather: [.init(phenomena: [.freezing, .fog])], temperature: -4, dewPoint: -4, automaticStation: true, remarks: "AO2 T10411044", flightRules: .lifr)
        try compareMETAR("K1S5 041235Z AUTO 00000KT M1 1/4SM FZFG OVC002 M04/M04 A3058 RMK AO2 T10411044", "K1S5", 4, 12, 35, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 30.58, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 200, unit: .feet))], visibility: .init(modifier: .lessThan, measurement: .init(value: 1.25, unit: .miles)), weather: [.init(phenomena: [.freezing, .fog])], temperature: -4, dewPoint: -4, automaticStation: true, remarks: "AO2 T10411044", flightRules: .lifr)
        try compareMETAR("K1S5 041235Z AUTO 00000KT M4SM FZFG OVC002 M04/M04 A3058 RMK AO2 T10411044", "K1S5", 4, 12, 35, wind: .init(direction: .direction(.init(value: 0, unit: .degrees)), speed: .init(value: 0, unit: .knots)), qnh: .init(value: 30.58, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 200, unit: .feet))], visibility: .init(modifier: .lessThan, measurement: .init(value: 4, unit: .miles)), weather: [.init(phenomena: [.freezing, .fog])], temperature: -4, dewPoint: -4, automaticStation: true, remarks: "AO2 T10411044", flightRules: .lifr)
        try compareMETAR("CYRB 041300Z 11026G34KT 3/8SM R35/5000V6000FT/U IC BLSN OVC005 M19/M22 A2984 RMK BLSN3ST8 PRESFR SLP118", "CYRB", 4, 13, 0, wind: .init(direction: .direction(.init(value: 110, unit: .degrees)), speed: .init(value: 26, unit: .knots), gustSpeed: .init(value: 34, unit: .knots)), qnh: .init(value: 29.84, unit: .inchesOfMercury), cloudLayers: [.init(coverage: .overcast, height: .init(value: 500, unit: .feet))], visibility: .init(measurement: .init(value: 0.375, unit: .miles)), rvrs: [.init(runway: "35", visibility: .init(measurement: .init(value: 5000, unit: .feet)), variableVisibility: .init(measurement: .init(value: 6000, unit: .feet)), trend: .increasing)], weather: [.init(phenomena: [.iceCrystals]), .init(phenomena: [.blowing, .snow])], temperature: -19, dewPoint: -22, remarks: "BLSN3ST8 PRESFR SLP118", flightRules: .lifr)
        try compareMETAR("EGXW 041250Z 26012KT 9999 5000SE -RADZ OVC003 01/00 Q0970 TEMPO 2000 -SN RMK BLACKYLO2 TEMPO YLO2", "EGXW", 4, 12, 50, wind: .init(direction: .direction(.init(value: 260, unit: .degrees)), speed: .init(value: 12, unit: .knots)), qnh: .init(value: 970, unit: .hectopascals), cloudLayers: [.init(coverage: .overcast, height: .init(value: 300, unit: .feet))], visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), weather: [.init(modifier: .light, phenomena: [.rain, .drizzle])], trends: [.init(metarRepresentation: .init(identifier: "EGXW", date: date(day: 4, hour: 12, minute: 50), visibility: .init(measurement: .init(value: 2000, unit: .meters)), weather: [.init(modifier: .light, phenomena: [.snow])], metarString: "2000 -SN", flightRules: .ifr), type: .temporaryForecast)], temperature: 1, dewPoint: 0, remarks: "BLACKYLO2 TEMPO YLO2", flightRules: .lifr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 Q1008", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 1008, unit: .hectopascals), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, flightRules: .vfr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 A2992 Q1013", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 29.92, unit: .inchesOfMercury), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, flightRules: .vfr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 Q1013 A2992", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 29.92, unit: .inchesOfMercury), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, flightRules: .vfr)
        try compareMETAR("ENHV 041350Z 18018KT 9999 CAVOK 02/M02 Q1013 A2992 A2991", "ENHV", 4, 13, 50, wind: .init(direction: .direction(.init(value: 180, unit: .degrees)), speed: .init(value: 18, unit: .knots)), qnh: .init(value: 29.92, unit: .inchesOfMercury), visibility: .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)), temperature: 2, dewPoint: -2, ceilingAndVisibilityOK: true, flightRules: .vfr)
        try compareMETAR("ENHF 041850Z VRB01KT CAVOK M00/M04 Q1007 RMK WIND 1254FT 18006KT", "ENHF", 4, 18, 50, wind: .init(direction: .variable, speed: .init(value: 1, unit: .knots)), qnh: .init(value: 1007, unit: .hectopascals), temperature: -0, dewPoint: -4, ceilingAndVisibilityOK: true, remarks: "WIND 1254FT 18006KT", flightRules: .vfr)
    }

    func testInvalidMETARs() {
        XCTAssertNil(METAR(rawMETAR: "KRDU 22007KT 9SM FEW080 FEW250 22/20 A3004 RMK AO2 SLP166 60000 T02170200 10222 20206 53022"))
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
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 33008G15KT 300V360")).wind, .init(direction: .direction(.init(value: 330, unit: .degrees)), speed: .init(value: 8, unit: .knots), gustSpeed: .init(value: 15, unit: .knots), variation: .init(from: .init(value: 300, unit: .degrees), to: .init(value: 360, unit: .degrees))))
    }

    func testVisbility() throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).visibility, .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 10SM")).visibility, .init(measurement: .init(value: 10, unit: .miles)))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 10SM")).visibility, .init(measurement: .init(value: 10, unit: .miles)))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 1 1/8SM")).visibility, .init(measurement: .init(value: 1.125, unit: .miles)))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 9999")).visibility, .init(modifier: .greaterThan, measurement: .init(value: 10, unit: .kilometers)))
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z P5SM")).visibility, .init(modifier: .greaterThan, measurement: .init(value: 5, unit: .miles)))
        try XCTAssertNil(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z CAVOK")).visibility)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z CAVOK")).isCeilingAndVisibilityOK, true)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EKTE 211720Z AUTO 22011KT 9999NDV NCD 11/10 Q1026=")).isCeilingAndVisibilityOK, false)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 10SM")).isCeilingAndVisibilityOK, false)
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: "EGGD 121212Z 9999")).isCeilingAndVisibilityOK, false)
    }

    private func compareMETAR(_ rawMETAR: String, _ identifier: String, _ day: Int, _ hour: Int, _ minute: Int, wind: Wind? = nil, qnh: Measurement<UnitPressure>? = nil, skyCondition: SkyCondition? = nil, cloudLayers: [CloudLayer] = [], visibility: Visibility? = nil, rvrs: [RunwayVisualRange] = [], weather: [Weather] = [], trends: [Trend] = [], militaryColourCode: MilitaryColourCode? = nil, temperature: Double? = nil, dewPoint: Double? = nil, ceilingAndVisibilityOK: Bool = false, automaticStation: Bool = false, correction: Bool = false, noSignificantChangesExpected: Bool = false, remarks: String? = nil, flightRules: NOAAFlightRules? = nil) throws {
        try XCTAssertEqual(XCTUnwrap(METAR(rawMETAR: rawMETAR)), XCTUnwrap(METAR(
            identifier: identifier,
            date: date(day: day, hour: hour, minute: minute),
            wind: wind,
            qnh: qnh,
            skyCondition: skyCondition,
            cloudLayers: cloudLayers,
            visibility: visibility,
            runwayVisualRanges: rvrs,
            weather: weather,
            trends: trends,
            militaryColourCode: militaryColourCode,
            temperature: temperature.map { .init(value: $0, unit: .celsius) },
            dewPoint: dewPoint.map { .init(value: $0, unit: .celsius) },
            isCeilingAndVisibilityOK: ceilingAndVisibilityOK,
            isAutomatic: automaticStation,
            isCorrection: correction,
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
