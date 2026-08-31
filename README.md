# Swift Open-Meteo

[Open-Meteo](https://open-meteo.com), typed: forecast, hourly, air quality, geocoding and the 1940-onwards archive — keyless, four endpoints, zero dependencies.

```swift
import OpenMeteo

let client = OpenMeteoClient()
let places = try await client.geocode("Bangkok")
let forecast = try await client.forecast(at: places[0].coordinates)
print(forecast.current?.temperature ?? 0, WeatherCode.describe(forecast.current?.weatherCode ?? -1))
// 28.4 moderate drizzle
```

## Features

- 🌤 **Forecast** — current conditions, 1–16 days of dailies, hourly on request
- 🫁 **Air quality** — PM2.5/PM10/O₃/NO₂ and **both** AQI scales, with band tables (`AQIBands`)
- 📍 **Geocoding** — place name → coordinates, country, timezone, population
- 📜 **History** — daily archive back to 1940
- 🗣 **WMO codes in words and symbols** — `WeatherCode.describe(53)` → "moderate drizzle", plus a terminal glyph and a 16-point compass
- 🌡 **Metric or imperial** — one switch, mapped to the API's own unit parameters
- 🔑 **No key, no signup** — and no dependency beyond Foundation

## Honesty notes

Every response field is optional and every JSON key is spelled out explicitly — Open-Meteo's names include digits (`temperature_2m`), which automatic snake-case conversion mangles. The geocoder omits `results` entirely when it knows nothing; that decodes as an empty list, not an error. When the API refuses a request it says why, and that reason is what the thrown error carries.

## Attribution

Weather data by [Open-Meteo.com](https://open-meteo.com), licensed CC BY 4.0. Anything shipping on this library owes that line.

## Requirements

macOS 14+ / iOS 16+, Swift 6.

## License

MIT — see LICENSE. The weather data itself is CC BY 4.0 Open-Meteo's.
