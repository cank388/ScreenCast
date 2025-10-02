//
//  CastManager.swift
//  ScreenCast
//
//  Created by Assistant on 1.10.2025.
//

import Foundation
import os.log
import GoogleCast

#if canImport(GoogleCast)

/// Manages Google Cast initialization.
final class CastManager: NSObject {
    static let shared = CastManager()

    private override init() { }

    /// Call once on app start to configure Cast context.
    func configure() {
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kGCKDefaultMediaReceiverApplicationID))
        GCKCastContext.setSharedInstanceWith(options)

        // Enable verbose Google Cast SDK logging
        GCKLogger.sharedInstance().delegate = self
        GCKLogger.sharedInstance().minimumLevel = .verbose

        // Observe session events
        GCKCastContext.sharedInstance().sessionManager.add(self)
        os_log("Cast configured", log: OSLog(subsystem: "ScreenCast", category: "Cast"), type: .info)
    }
}

extension CastManager: GCKLoggerDelegate {
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        let logger = OSLog(subsystem: "ScreenCast", category: "CastSDK")
        os_log("[%{public}@][%{public}@] %{public}@", log: logger, type: .debug, level.description, function, message)
    }
}

extension GCKLoggerLevel {
    var description: String { String(describing: self) }
}

extension CastManager: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKSession) {
        os_log("willStart session: %{public}@", log: OSLog(subsystem: "ScreenCast", category: "CastSession"), type: .info, String(describing: type(of: session)))
    }
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        os_log("didStart session", log: OSLog(subsystem: "ScreenCast", category: "CastSession"), type: .info)
    }
    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        os_log("didFailToStart: %{public}@", log: OSLog(subsystem: "ScreenCast", category: "CastSession"), type: .error, error.localizedDescription)
    }
    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKSession) {
        os_log("willEnd session", log: OSLog(subsystem: "ScreenCast", category: "CastSession"), type: .info)
    }
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        if let error = error {
            os_log("didEnd with error: %{public}@", log: OSLog(subsystem: "ScreenCast", category: "CastSession"), type: .error, error.localizedDescription)
        } else {
            os_log("didEnd successfully", log: OSLog(subsystem: "ScreenCast", category: "CastSession"), type: .info)
        }
    }
}
#else
/// Placeholder when GoogleCast SDK is not linked.
final class CastManager: NSObject {
    static let shared = CastManager()
    private override init() { }
    func configure() { /* no-op */ }
}
#endif


