# METAR

This is a simple regular expression based METAR parser.

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
