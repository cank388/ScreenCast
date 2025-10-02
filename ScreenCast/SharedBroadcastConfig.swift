//
//  SharedBroadcastConfig.swift
//  ScreenCast
//
//  Created by Assistant on 1.10.2025.
//

import Foundation

/// Shared storage and constants for app and broadcast extension.
/// Uses App Group to share RTMP URL between main app and extension.
final class SharedBroadcastConfig {
    static let shared = SharedBroadcastConfig()

    private init() {}

    // Change this to your App Group identifier configured in Signing & Capabilities
    private let appGroupIdentifier = "group.kalender.ScreenCast"

    private let rtmpURLKey = "rtmp_url"
    private let extensionBundleIdKey = "broadcast_extension_bundle_id"

    /// Returns the shared UserDefaults for the App Group
    private func sharedDefaults() -> UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    /// Reads RTMP URL from shared defaults
    func readRTMPURL() -> String? {
        return sharedDefaults()?.string(forKey: rtmpURLKey)
    }

    /// Saves RTMP URL to shared defaults
    func saveRTMPURL(_ url: String) {
        sharedDefaults()?.set(url, forKey: rtmpURLKey)
    }

    /// Returns extension bundle identifier used by RPSystemBroadcastPickerView
    func extensionBundleIdentifier() -> String? {
        if let id = sharedDefaults()?.string(forKey: extensionBundleIdKey), !id.isEmpty {
            return id
        }
        // Provide a default guess; replace with your actual extension bundle id
        let defaultId = Bundle.main.bundleIdentifier?.appending("BroadcastUpload")
        return defaultId
    }

    /// Stores the extension bundle identifier in shared defaults (optional)
    func saveExtensionBundleIdentifier(_ identifier: String) {
        sharedDefaults()?.set(identifier, forKey: extensionBundleIdKey)
    }
}


