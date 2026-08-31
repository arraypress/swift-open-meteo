//
//  Forecast.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  The forecast envelope: where, when, now, and the series asked for.
//

import Foundation

/// A forecast: where, when, now, and the series asked for.
public struct Forecast: Codable, Sendable {

    /// Latitude of the model grid cell actually used.
    public let latitude: Double?

    /// Longitude of the grid cell.
    public let longitude: Double?

    /// IANA timezone the local stamps are in.
    public let timezone: String?

    /// Short zone name, e.g. `GMT+7`.
    public let timezoneAbbreviation: String?

    /// Conditions now, when requested.
    public let current: CurrentWeather?

    /// Hourly series, when requested.
    public let hourly: HourlySeries?

    /// Daily series, when requested.
    public let daily: DailySeries?

    /// Units per current field, exactly as the API states them.
    public let currentUnits: [String: String]?

    /// Units per hourly field.
    public let hourlyUnits: [String: String]?

    /// Units per daily field.
    public let dailyUnits: [String: String]?

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, current, hourly, daily
        case timezoneAbbreviation = "timezone_abbreviation"
        case currentUnits = "current_units"
        case hourlyUnits = "hourly_units"
        case dailyUnits = "daily_units"
    }
}
