//
//  HourlySeries.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  The hourly series: parallel arrays, one entry per stamp.
//

import Foundation

/// Hour-by-hour series, parallel arrays keyed by ``time``.
public struct HourlySeries: Codable, Sendable {

    /// Local hour stamps, ISO 8601 without zone.
    public let time: [String]

    /// Temperature at 2 m per hour.
    public let temperature: [Double?]?

    /// Chance of precipitation per hour, percent.
    public let precipitationProbability: [Double?]?

    /// WMO code per hour.
    public let weatherCode: [Int?]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
    }
}
