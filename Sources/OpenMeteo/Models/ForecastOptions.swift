//
//  ForecastOptions.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  What a forecast should include; the defaults are what `weather <place>` shows.
//

import Foundation

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
