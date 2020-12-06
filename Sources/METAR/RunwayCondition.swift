//
//  RunwayCondition.swift
//  
//
//  Created by Jonathan Downing on 12/5/20.
//

import Foundation

public struct RunwayCondition: Equatable {

    public enum RunwayDesignation: Equatable {

        case runway(String)
        case allRunways
        case previousRunwayReportRepeated

    }

    public enum DepositType {

        case clearAndDry
        case damp
        case wetOrWaterPatches
        case rimeOrFrost
        case drySnow
        case wetSnow
        case slush
        case ice
        case compactedOrRolledSnow
        case frozenRutsOrRidges
        case notReported

    }

    public enum ContaminationExtent {

        /// 10% or less of runway covered
        case minimal

        /// 11% to 25% of runway covered
        case low

        /// 26% to 50% or runway covered
        case medium

        /// 51% to 100% of runway covered
        case high

        /// Not reported (For example due to runway clearance in progress)
        case notReported

    }

    public enum DepositDepth: Equatable {

        /// Less than 1mm
        case minimal

        /// Depth in millimeters
        case depth(Measurement<UnitLength>)

        /// Runway not operational due to contamination or clearance in progress
        case runwayNotOperational

        /// Depth is insignificant due to ice or immesurable due to wet
        case depthNotSignificant

    }

    public enum BrakingConditions: Equatable {

        case frictionCoefficient(Double)
        case poor
        case poorMedium
        case medium
        case mediumGood
        case good
        case unreliableOrNotMeasurable

    }

    public enum ReportType: Equatable {
        case airportClosedDueToSnow
        case contaiminationDisappeared(BrakingConditions)
        case `default`(DepositType, ContaminationExtent, DepositDepth, BrakingConditions)
        case reportNotUpdated
    }

    public var runwayDesignation: RunwayDesignation
    public var reportType: ReportType

}
