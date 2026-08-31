//
//  OpenMeteoError.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  What can go wrong talking to Open-Meteo, with the API's own reason
//  surfaced whenever it gives one.
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
