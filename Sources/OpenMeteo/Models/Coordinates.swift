//
//  Coordinates.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  A point on the globe, the way every endpoint wants it.
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
