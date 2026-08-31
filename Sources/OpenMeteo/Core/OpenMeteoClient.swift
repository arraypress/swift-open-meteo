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
        let envelope: GeocodingResponse = try await get(Endpoints.geocode(name, count: count, language: language))
        return envelope.results ?? []
    }

    /// The forecast at a point: current conditions, daily series, and the
    /// hourly series when asked.
    public func forecast(at point: Coordinates, options: ForecastOptions = ForecastOptions()) async throws -> Forecast {
        return try await get(Endpoints.forecast(at: point, options: options))
    }

    /// Air quality at a point, on both the European and US indices.
    public func airQuality(at point: Coordinates) async throws -> AirQuality {
        return try await get(Endpoints.airQuality(at: point))
    }

    /// Past daily weather between two dates (`YYYY-MM-DD`, inclusive).
    /// The archive runs from 1940 to about a week ago.
    public func history(at point: Coordinates, from: String, to: String, units: UnitSystem = .metric) async throws -> History {
        return try await get(Endpoints.history(at: point, from: from, to: to, units: units))
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
