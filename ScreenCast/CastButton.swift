//
//  CastButton.swift
//  ScreenCast
//
//  Created by Assistant on 1.10.2025.
//

import SwiftUI
import GoogleCast

#if canImport(GoogleCast)

/// SwiftUI bridge for Google Cast button.
struct CastButton: UIViewRepresentable {
    func makeUIView(context: Context) -> GCKUICastButton {
        let button = GCKUICastButton(type: .system)
        button.tintColor = .systemBlue
        return button
    }

    func updateUIView(_ uiView: GCKUICastButton, context: Context) {
        // No-op
    }
}
#else
/// Placeholder when Google Cast SDK is not linked.
struct CastButton: View {
    var body: some View {
        HStack {
            Image(systemName: "tv.badge.wifi")
            Text("Chromecast hazır değil")
        }
        .foregroundStyle(.secondary)
    }
}
#endif


