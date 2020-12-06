//
//  METAR+Date.swift
//  
//
//  Created by Jonathan Downing on 12/6/20.
//

import Foundation

extension METAR {

    /// The date the report was issued.
    ///
    /// Since METARs only encode day, hour, and minute information—the date from this property is the
    /// most recent date in the past matching those date components. If the METAR is recent, this should
    /// not be a problem.
    public var date: Date {
        date(relativeTo: Date())
    }

    func date(relativeTo referenceDate: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)

        var dateComponents = self.dateComponents
        dateComponents.year = calendar.component(.year, from: referenceDate)
        dateComponents.month = calendar.component(.month, from: referenceDate)

        guard var date = calendar.date(from: dateComponents) else { return .distantPast }

        if date > referenceDate {
            dateComponents.month! -= 1
            date = calendar.date(from: dateComponents) ?? .distantPast
        }

        return date
    }

}
