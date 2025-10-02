//
//  ScreenCastApp.swift
//  ScreenCast
//
//  Created by Can Kalender on 1.10.2025.
//

import SwiftUI
import AVKit
import Foundation

@main
struct ScreenCastApp: App {
    init() {
        // Configure AirPlay audio session for better interoperability
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
        } catch {
            // fallback silently
        }

        // Configure Google Cast if available
        CastManager.shared.configure()

        // Prepare shared defaults with initial RTMP URL placeholder if not set
        if SharedBroadcastConfig.shared.readRTMPURL() == nil {
            SharedBroadcastConfig.shared.saveRTMPURL("")
        }
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}
