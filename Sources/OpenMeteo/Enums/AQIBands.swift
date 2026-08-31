//
//  AQIBands.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  Air-quality index bands, named the way each scale names them — the
//  number alone tells nobody whether to open the window.
//

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
