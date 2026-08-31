//
//  History.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Past weather: the daily series between two dates.
//

import Foundation

/// Past weather: the daily series between two dates.
public struct History: Codable, Sendable {

    /// IANA timezone the dates are in.
    public let timezone: String?

    /// The daily series.
    public let daily: DailySeries?

    /// Units per daily field.
    public let dailyUnits: [String: String]?

    enum CodingKeys: String, CodingKey {
        case timezone, daily
        case dailyUnits = "daily_units"
    }
}
