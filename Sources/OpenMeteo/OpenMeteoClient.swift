//
//  OpenMeteoClient.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  The client: four endpoints, no key, no state. Open-Meteo's data is
//  CC BY 4.0 — anything shipping on this library owes the attribution
//  "Weather data by Open-Meteo.com".
//

import Foundation

/// What can go wrong talking to Open-Meteo.
public enum OpenMeteoError: Error, LocalizedError, Sendable {

    /// The API refused the request and said why.
    case api(String)

    /// The response was not HTTP 200 and carried no reason.
    case badStatus(Int)

    /// The payload did not decode as expected.
    case decoding(String)

    public var errorDescription: String? {
        switch self {
        case .api(let reason): return "Open-Meteo: \(reason)"
        case .badStatus(let code): return "Open-Meteo answered HTTP \(code)"
        case .decoding(let detail): return "Open-Meteo's response did not decode: \(detail)"
        }
    }
}

/// Which measurement system values arrive in.
public enum UnitSystem: String, CaseIterable, Sendable {

    /// °C, km/h, mm — the API's native units.
    case metric

    /// °F, mph, inch.
    case imperial

    /// The query items that switch the API over, empty for metric.
    var queryItems: [URLQueryItem] {
        switch self {
        case .metric: return []
        case .imperial: return [
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "precipitation_unit", value: "inch"),
        ]
        }
    }
}

/// What a forecast should include.
public struct ForecastOptions: Sendable {

    /// Days of daily forecast, 1…16.
    public var days: Int

    /// Whether the hourly series rides along.
    public var includeHourly: Bool

    /// The measurement system.
    public var units: UnitSystem

    /// Options; the defaults are what `weather <place>` shows.
    public init(days: Int = 7, includeHourly: Bool = false, units: UnitSystem = .metric) {
        self.days = days
        self.includeHourly = includeHourly
        self.units = units
    }
}

/// Open-Meteo, typed. One instance is enough; it holds only a session.
public struct OpenMeteoClient: Sendable {

    private let session: URLSession

    /// A client on the given session.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Places matching a name, best first. Empty when the geocoder knows
    /// nothing by that name.
    public func geocode(_ name: String, count: Int = 5, language: String = "en") async throws -> [Place] {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: String(count)),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "format", value: "json"),
        ]
        let envelope: GeocodingResponse = try await get(components)
        return envelope.results ?? []
    }

    /// The forecast at a point: current conditions, daily series, and the
    /// hourly series when asked.
    public func forecast(at point: Coordinates, options: ForecastOptions = ForecastOptions()) async throws -> Forecast {
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
        return try await get(components)
    }

    /// Air quality at a point, on both the European and US indices.
    public func airQuality(at point: Coordinates) async throws -> AirQuality {
        var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(point.latitude)),
            URLQueryItem(name: "longitude", value: String(point.longitude)),
            URLQueryItem(name: "current", value: "pm2_5,pm10,ozone,nitrogen_dioxide,sulphur_dioxide,carbon_monoxide,european_aqi,us_aqi"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]
        return try await get(components)
    }

    /// Past daily weather between two dates (`YYYY-MM-DD`, inclusive).
    /// The archive runs from 1940 to about a week ago.
    public func history(at point: Coordinates, from: String, to: String, units: UnitSystem = .metric) async throws -> History {
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
        return try await get(components)
    }

    // MARK: The one fetch

    /// GETs and decodes, surfacing the API's own `reason` when it refuses.
    private func get<T: Decodable>(_ components: URLComponents) async throws -> T {
        guard let url = components.url else { throw OpenMeteoError.decoding("bad URL components") }
        var request = URLRequest(url: url)
        request.setValue("swift-open-meteo (github.com/arraypress/swift-open-meteo)", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status != 200 {
            if let failure = try? JSONDecoder().decode(APIFailure.self, from: data), let reason = failure.reason {
                throw OpenMeteoError.api(reason)
            }
            throw OpenMeteoError.badStatus(status)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw OpenMeteoError.decoding(String(describing: error))
        }
    }
}
