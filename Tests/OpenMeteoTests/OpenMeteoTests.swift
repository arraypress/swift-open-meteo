//
//  OpenMeteoTests.swift
//  OpenMeteoTests
//
//  Created by David Sherlock on 2026.
//
//  Recorded responses from 2026-08-31 decode into the exact values the
//  fixtures carry; the WMO and AQI tables answer at their edges; and the
//  unit switch emits precisely the query items the API documents. No
//  network anywhere.
//

import Foundation
import XCTest
@testable import OpenMeteo

final class OpenMeteoTests: XCTestCase {

    private func fixture(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Fixtures/\(name)", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    func testForecastFixtureDecodes() throws {
        let forecast = try JSONDecoder().decode(Forecast.self, from: try fixture("forecast"))
        XCTAssertEqual(forecast.timezone, "Asia/Bangkok")
        XCTAssertEqual(forecast.timezoneAbbreviation, "GMT+7")
        let current = try XCTUnwrap(forecast.current)
        XCTAssertEqual(current.temperature, 28.4)
        XCTAssertEqual(current.humidity, 84)
        XCTAssertEqual(current.feelsLike, 34.8)
        XCTAssertEqual(current.weatherCode, 53)
        XCTAssertEqual(current.windDirection, 229)
        let daily = try XCTUnwrap(forecast.daily)
        XCTAssertEqual(daily.time.count, 7)
        XCTAssertEqual(daily.temperatureMax?.count, 7)
        XCTAssertEqual(forecast.currentUnits?["temperature_2m"], "°C")
        let hourly = try XCTUnwrap(forecast.hourly)
        XCTAssertEqual(hourly.time.count, 7 * 24)
    }

    func testAirQualityFixtureDecodes() throws {
        let air = try JSONDecoder().decode(AirQuality.self, from: try fixture("air"))
        let current = try XCTUnwrap(air.current)
        XCTAssertEqual(current.pm25, 6.7)
        XCTAssertEqual(current.pm10, 9.3)
        XCTAssertEqual(current.europeanAQI, 24)
        XCTAssertEqual(current.usAQI, 28)
        XCTAssertEqual(current.carbonMonoxide, 840.0)
    }

    func testGeocodingFixturesDecode() throws {
        let hits = try JSONDecoder().decode(GeocodingResponse.self, from: try fixture("geocode"))
        let first = try XCTUnwrap(hits.results?.first)
        XCTAssertEqual(first.name, "Bangkok")
        XCTAssertEqual(first.countryCode, "TH")
        XCTAssertEqual(first.timezone, "Asia/Bangkok")
        XCTAssertEqual(first.coordinates.latitude, 13.75398, accuracy: 0.0001)
        // The empty result: the API omits `results` entirely rather than
        // sending an empty array. Absence must read as "no places".
        let empty = try JSONDecoder().decode(GeocodingResponse.self, from: try fixture("geocode-empty"))
        XCTAssertNil(empty.results)
    }

    func testHistoryFixtureDecodes() throws {
        let history = try JSONDecoder().decode(History.self, from: try fixture("history"))
        let daily = try XCTUnwrap(history.daily)
        XCTAssertEqual(daily.time.first, "2026-01-01")
        XCTAssertEqual(daily.time.count, 31)
        XCTAssertEqual(history.dailyUnits?["precipitation_sum"], "mm")
    }

    func testWeatherCodeTableSpeaksEveryDocumentedCode() {
        XCTAssertEqual(WeatherCode.describe(0), "clear sky")
        XCTAssertEqual(WeatherCode.describe(53), "moderate drizzle")
        XCTAssertEqual(WeatherCode.describe(95), "thunderstorm")
        XCTAssertEqual(WeatherCode.describe(999), "unknown conditions (code 999)")
        // Every code Open-Meteo documents has words and a symbol that is not
        // the ignorance glyph.
        let documented = [0, 1, 2, 3, 45, 48, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67,
                          71, 73, 75, 77, 80, 81, 82, 85, 86, 95, 96, 99]
        for code in documented {
            XCTAssertFalse(WeatherCode.describe(code).hasPrefix("unknown"), "\(code)")
            XCTAssertNotEqual(WeatherCode.symbol(code), "❓", "\(code)")
        }
        XCTAssertEqual(WeatherCode.compass(0), "N")
        XCTAssertEqual(WeatherCode.compass(229), "SW")
        XCTAssertEqual(WeatherCode.compass(359), "N")
    }

    func testAQIBandsAtTheirEdges() {
        XCTAssertEqual(AQIBands.european(19), "good")
        XCTAssertEqual(AQIBands.european(20), "fair")
        XCTAssertEqual(AQIBands.european(99), "very poor")
        XCTAssertEqual(AQIBands.european(140), "extremely poor")
        XCTAssertEqual(AQIBands.us(50), "good")
        XCTAssertEqual(AQIBands.us(51), "moderate")
        XCTAssertEqual(AQIBands.us(101), "unhealthy for sensitive groups")
        XCTAssertEqual(AQIBands.us(301), "hazardous")
    }

    func testUnitSwitchEmitsTheDocumentedQueryItems() {
        XCTAssertTrue(UnitSystem.metric.queryItems.isEmpty, "metric is the API's native voice")
        let imperial = Dictionary(uniqueKeysWithValues: UnitSystem.imperial.queryItems.map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(imperial["temperature_unit"], "fahrenheit")
        XCTAssertEqual(imperial["wind_speed_unit"], "mph")
        XCTAssertEqual(imperial["precipitation_unit"], "inch")
    }

    /// The query grammar is the API contract; pin it with no network.
    func testEndpointsCarryTheContract() {
        func items(_ c: URLComponents) -> [String: String] {
            Dictionary(uniqueKeysWithValues: (c.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        }
        let clamped = items(Endpoints.forecast(at: Coordinates(latitude: 1, longitude: 2), options: ForecastOptions(days: 99)))
        XCTAssertEqual(clamped["forecast_days"], "16")
        XCTAssertNil(clamped["hourly"])
        let imperial = items(Endpoints.forecast(at: Coordinates(latitude: 1, longitude: 2), options: ForecastOptions(days: 0, includeHourly: true, units: .imperial)))
        XCTAssertEqual(imperial["forecast_days"], "1")
        XCTAssertEqual(imperial["temperature_unit"], "fahrenheit")
        XCTAssertEqual(imperial["wind_speed_unit"], "mph")
        XCTAssertEqual(items(Endpoints.geocode("Bang kok", count: 3, language: "en"))["count"], "3")
        let past = items(Endpoints.history(at: Coordinates(latitude: 1, longitude: 2), from: "2026-01-01", to: "2026-01-31", units: .metric))
        XCTAssertEqual(past["start_date"], "2026-01-01")
        XCTAssertNil(past["temperature_unit"])
    }
}
