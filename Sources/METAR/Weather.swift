//
//  Weather.swift
//  
//
//  Created by Jonathan Downing on 12/5/20.
//

public struct Weather: Hashable {

    public enum Modifier {
        case light
        case moderate
        case heavy
        case inTheVicinity
        case recent
    }

    public enum Phenomena {
        case shallow
        case partial
        case patches
        case lowDrifting
        case blowing
        case showers
        case thunderstorm
        case freezing
        case drizzle
        case rain
        case snow
        case snowGrains
        case iceCrystals
        case icePellets
        case hail
        case snowPellets
        case unknownPrecipitation
        case mist
        case fog
        case smoke
        case volcanicAsh
        case sand
        case haze
        case spray
        case widespreadDust
        case duststorm
        case sandstorm
        case squalls
        case funnelCloud
        case wellDevelopedDustWhirls
    }

    public var modifier: Modifier = .moderate
    public var phenomena: [Phenomena] = []

}
