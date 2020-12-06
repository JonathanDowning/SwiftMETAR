//
//  NOAAFlightRules.swift
//  
//
//  Created by Jonathan Downing on 12/4/20.
//

public enum ICAOFlightRules {

    /// Visual Meteorlogical Conditions
    ///
    /// Applicable when either are true:
    /// - Ceiling is greater than or equal to 1,500 feet.
    /// - Visibility is greater than or equal to 5,000 meters.
    case vmc

    /// Instrument Meteorlogical Conditions
    ///
    /// Applicable when either are true:
    /// - Ceiling is less than 1,500 feet.
    /// - Visibility is less than 5,000 meters.
    case imc

}

public enum NOAAFlightRules {

    /// Visual Flight Rules
    ///
    /// Applicable when both are true:
    /// - Ceiling is greater than 3,000 feet
    /// - Visibility is greater than 5 miles
    case vfr

    /// Marginal Visual Flight Rules
    ///
    /// Applicable when either are true:
    /// - Ceiling is greater than or equal to 1,000 feet and less than or equal to 3,000 feet
    /// - Visibility is greater than or equal to 3 miles and less than or equal to 5 miles.
    case mvfr

    /// Instrument Flight Rules
    ///
    /// Applicable when either are true:
    /// - Ceiling is greater than or equal to 500 feet and less than 1,000 feet
    /// - Visibility is greater than or equal to 1 mile and less than 3 miles.
    case ifr

    /// Low Instrument Flight Rules
    ///
    /// Applicable when either are true:
    /// - Ceiling is less than 500 feet
    /// - Visibility is less than 1 mile
    case lifr
    
}
