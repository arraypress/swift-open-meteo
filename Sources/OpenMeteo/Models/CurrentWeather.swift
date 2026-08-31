//
//  CurrentWeather.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Conditions at this moment, as the forecast endpoint reports them.
//

import Foundation

/// Conditions right now.
public struct CurrentWeather: Codable, Sendable {

    /// Local time of the reading, ISO 8601 without zone.
    public let time: String?

    /// Air temperature at 2 m.
    public let temperature: Double?

    /// Relative humidity at 2 m, percent.
    public let humidity: Double?

    /// What it feels like, combining wind and humidity.
    public let feelsLike: Double?

    /// Precipitation in the current interval.
    public let precipitation: Double?

    /// WMO weather interpretation code — words via ``WeatherCode``.
    public let weatherCode: Int?

    /// Wind speed at 10 m.
    public let windSpeed: Double?

    /// Wind direction at 10 m, degrees.
    public let windDirection: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case humidity = "relative_humidity_2m"
        case feelsLike = "apparent_temperature"
        case precipitation
        case weatherCode = "weather_code"
        case windSpeed = "wind_speed_10m"
        case windDirection = "wind_direction_10m"
    }
}
