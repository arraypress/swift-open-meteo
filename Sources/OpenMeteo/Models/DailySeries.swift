//
//  DailySeries.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  The daily series: parallel arrays, one entry per day.
//

import Foundation

/// Day-by-day series, parallel arrays keyed by ``time``.
public struct DailySeries: Codable, Sendable {

    /// Dates, `YYYY-MM-DD`.
    public let time: [String]

    /// Daily maximum temperature.
    public let temperatureMax: [Double?]?

    /// Daily minimum temperature.
    public let temperatureMin: [Double?]?

    /// Highest precipitation chance in the day, percent.
    public let precipitationProbabilityMax: [Double?]?

    /// Total precipitation for the day.
    public let precipitationSum: [Double?]?

    /// WMO code summarising the day.
    public let weatherCode: [Int?]?

    /// Local sunrise stamps.
    public let sunrise: [String]?

    /// Local sunset stamps.
    public let sunset: [String]?

    enum CodingKeys: String, CodingKey {
        case time, sunrise, sunset
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case precipitationSum = "precipitation_sum"
        case weatherCode = "weather_code"
    }
}
