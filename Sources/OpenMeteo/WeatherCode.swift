//
//  WeatherCode.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  WMO 4677 weather interpretation codes, as Open-Meteo emits them, in
//  words and symbols. The table follows Open-Meteo's own documentation of
//  the code set (docs → "WMO Weather interpretation codes"); codes it does
//  not emit fall through to a plain description of ignorance.
//

/// WMO weather codes as words and symbols.
public enum WeatherCode {

    /// The condition in plain words, e.g. `53` → "moderate drizzle".
    public static func describe(_ code: Int) -> String {
        switch code {
        case 0: return "clear sky"
        case 1: return "mainly clear"
        case 2: return "partly cloudy"
        case 3: return "overcast"
        case 45: return "fog"
        case 48: return "depositing rime fog"
        case 51: return "light drizzle"
        case 53: return "moderate drizzle"
        case 55: return "dense drizzle"
        case 56: return "light freezing drizzle"
        case 57: return "dense freezing drizzle"
        case 61: return "slight rain"
        case 63: return "moderate rain"
        case 65: return "heavy rain"
        case 66: return "light freezing rain"
        case 67: return "heavy freezing rain"
        case 71: return "slight snowfall"
        case 73: return "moderate snowfall"
        case 75: return "heavy snowfall"
        case 77: return "snow grains"
        case 80: return "slight rain showers"
        case 81: return "moderate rain showers"
        case 82: return "violent rain showers"
        case 85: return "slight snow showers"
        case 86: return "heavy snow showers"
        case 95: return "thunderstorm"
        case 96: return "thunderstorm with slight hail"
        case 99: return "thunderstorm with heavy hail"
        default: return "unknown conditions (code \(code))"
        }
    }

    /// A one-glyph sky for terminals, e.g. `53` → 🌦.
    public static func symbol(_ code: Int) -> String {
        switch code {
        case 0: return "☀️"
        case 1: return "🌤"
        case 2: return "⛅️"
        case 3: return "☁️"
        case 45, 48: return "🌫"
        case 51, 53, 55, 56, 57: return "🌦"
        case 61, 63, 65, 66, 67, 80, 81, 82: return "🌧"
        case 71, 73, 75, 77, 85, 86: return "🌨"
        case 95, 96, 99: return "⛈"
        default: return "❓"
        }
    }

    /// A compass point for a wind direction in degrees, e.g. `229` → "SW".
    public static func compass(_ degrees: Double) -> String {
        let points = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees / 22.5) + 0.5) % 16
        return points[(index + 16) % 16]
    }
}

/// Air-quality index bands, named the way the scales name them.
public enum AQIBands {

    /// The European AQI band (EAQI, CAMS): 0–20 good … above 100 extremely poor.
    public static func european(_ value: Int) -> String {
        switch value {
        case ..<20: return "good"
        case 20..<40: return "fair"
        case 40..<60: return "moderate"
        case 60..<80: return "poor"
        case 80..<100: return "very poor"
        default: return "extremely poor"
        }
    }

    /// The United States AQI band (EPA): 0–50 good … above 300 hazardous.
    public static func us(_ value: Int) -> String {
        switch value {
        case ...50: return "good"
        case 51...100: return "moderate"
        case 101...150: return "unhealthy for sensitive groups"
        case 151...200: return "unhealthy"
        case 201...300: return "very unhealthy"
        default: return "hazardous"
        }
    }
}
