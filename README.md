# METAR Parser for Swift

SwiftMETAR provides a simple way to parse METARs into Swift types.

## Usage Example

``` swift
import METAR

let metar = METAR("EGLL 290420Z AUTO 05005KT 020V090 7000 R04/1300VP2000U OVC005 09/08 Q1024 TEMPO BKN004")
print(metar?.visibility?.measurement) // Prints: Optional(7000.0 m)
print(metar?.temperature?.measurement) // Prints: Optional(9.0 °C)
print(metar?.qnh?.measurement) // Prints: Optional(1024.0 hPa)
print(metar?.wind?.speed.measurement) // Prints: Optional(5.0 kn)
print(metar?.runwayVisualRanges) // Prints: Optional([Runway 04: 1300.0 m – >2000.0 m Increasing])
```

## Contribution

If you'd like to contribute, please feel free to create a PR.

## License

SwiftMETAR is available under the MIT license. See the LICENSE file for more info.
