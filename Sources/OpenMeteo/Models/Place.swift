//
//  Place.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  A place the geocoder knows, and the internal envelope it arrives in.
//

import Foundation

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
