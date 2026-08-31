//
//  UnitSystem.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Which measurement system values arrive in, and the query items that
//  switch the API over.
//

import Foundation

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
