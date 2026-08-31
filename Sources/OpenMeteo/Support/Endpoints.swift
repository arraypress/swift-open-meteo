//
//  Endpoints.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Every request URL the client makes, built in one testable place — the
//  query grammar is the API contract, and a test should pin it without a
//  network in the room.
//

import Foundation

/// The request URLs, one builder per endpoint.
enum Endpoints {

    /// The geocoder: a name to places.
    static func geocode(_ name: String, count: Int, language: String) -> URLComponents {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: String(count)),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "format", value: "json"),
        ]
        return components
    }

    /// The forecast, with days clamped to the API's 1…16.
    static func forecast(at point: Coordinates, options: ForecastOptions) -> URLComponents {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        var items = [
            URLQueryItem(name: "latitude", value: String(point.latitude)),
            URLQueryItem(name: "longitude", value: String(point.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,precipitation"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum,weather_code,sunrise,sunset"),
            URLQueryItem(name: "forecast_days", value: String(max(1, min(16, options.days)))),
            URLQueryItem(name: "timezone", value: "auto"),
        ]
        if options.includeHourly {
            items.append(URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,weather_code"))
        }
        items.append(contentsOf: options.units.queryItems)
        components.queryItems = items
        return components
    }

    /// Air quality on both indices.
    static func airQuality(at point: Coordinates) -> URLComponents {
        var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(point.latitude)),
            URLQueryItem(name: "longitude", value: String(point.longitude)),
            URLQueryItem(name: "current", value: "pm2_5,pm10,ozone,nitrogen_dioxide,sulphur_dioxide,carbon_monoxide,european_aqi,us_aqi"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]
        return components
    }

    /// The archive between two `YYYY-MM-DD` dates, inclusive.
    static func history(at point: Coordinates, from: String, to: String, units: UnitSystem) -> URLComponents {
        var components = URLComponents(string: "https://archive-api.open-meteo.com/v1/archive")!
        var items = [
            URLQueryItem(name: "latitude", value: String(point.latitude)),
            URLQueryItem(name: "longitude", value: String(point.longitude)),
            URLQueryItem(name: "start_date", value: from),
            URLQueryItem(name: "end_date", value: to),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]
        items.append(contentsOf: units.queryItems)
        components.queryItems = items
        return components
    }
}
