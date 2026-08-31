//
//  APIFailure.swift
//  OpenMeteo
//
//  Created by David Sherlock on 2026.
//
//  The API's own failure envelope, decoded to surface its reason.
//

import Foundation

/// The API's own failure envelope: `{"error": true, "reason": "…"}`.
struct APIFailure: Codable {
    let error: Bool?
    let reason: String?
}
