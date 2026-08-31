//
//  AirQuality.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Air quality now, and its envelope — both indices carried.
//

import Foundation

/// Air quality right now.
public struct CurrentAirQuality: Codable, Sendable {

    /// Local time of the reading.
    public let time: String?

    /// Fine particulate matter ≤ 2.5 µm, µg/m³.
    public let pm25: Double?

    /// Particulate matter ≤ 10 µm, µg/m³.
    public let pm10: Double?

    /// Ozone, µg/m³.
    public let ozone: Double?

    /// Nitrogen dioxide, µg/m³.
    public let nitrogenDioxide: Double?

    /// Sulphur dioxide, µg/m³.
    public let sulphurDioxide: Double?

    /// Carbon monoxide, µg/m³.
    public let carbonMonoxide: Double?

    /// European air-quality index — bands via ``AQIBands/european(_:)``.
    public let europeanAQI: Int?

    /// United States AQI — bands via ``AQIBands/us(_:)``.
    public let usAQI: Int?

    enum CodingKeys: String, CodingKey {
        case time, pm10, ozone
        case pm25 = "pm2_5"
        case nitrogenDioxide = "nitrogen_dioxide"
        case sulphurDioxide = "sulphur_dioxide"
        case carbonMonoxide = "carbon_monoxide"
        case europeanAQI = "european_aqi"
        case usAQI = "us_aqi"
    }
}

/// The air-quality envelope.
public struct AirQuality: Codable, Sendable {

    /// IANA timezone the stamp is in.
    public let timezone: String?

    /// The current reading.
    public let current: CurrentAirQuality?

    enum CodingKeys: String, CodingKey {
        case timezone, current
    }
}
