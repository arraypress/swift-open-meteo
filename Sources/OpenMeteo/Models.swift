//
//  Models.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Open-Meteo's responses as tolerant values. Every field is optional and
//  every key is spelled out — the API's snake_case names include digits
//  ("temperature_2m"), which Foundation's automatic conversion mangles, so
//  nothing here trusts a strategy it cannot see.
//

import Foundation

/// A point on the planet.
public struct Coordinates: Sendable, Equatable {

    /// Degrees north.
    public let latitude: Double

    /// Degrees east.
    public let longitude: Double

    /// A coordinate pair.
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// One place the geocoder knows.
public struct Place: Codable, Sendable {

    /// GeoNames identifier.
    public let id: Int?

    /// The place's own name.
    public let name: String

    /// Degrees north.
    public let latitude: Double

    /// Degrees east.
    public let longitude: Double

    /// ISO country code, e.g. `TH`.
    public let countryCode: String?

    /// The country's name.
    public let country: String?

    /// First-level region — a state, province or prefecture.
    public let admin1: String?

    /// IANA timezone identifier.
    public let timezone: String?

    /// Resident population, where GeoNames knows it.
    public let population: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, country, admin1, timezone, population
        case countryCode = "country_code"
    }

    /// The place's coordinates.
    public var coordinates: Coordinates { Coordinates(latitude: latitude, longitude: longitude) }
}

/// The geocoder's envelope.
struct GeocodingResponse: Codable {
    let results: [Place]?
}

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

/// The API's own failure envelope: `{"error": true, "reason": "…"}`.
struct APIFailure: Codable {
    let error: Bool?
    let reason: String?
}
