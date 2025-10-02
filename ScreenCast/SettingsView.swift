//
//  SettingsView.swift
//  ScreenCast
//
//  Created by Assistant on 1.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var rtmpURL: String = SharedBroadcastConfig.shared.readRTMPURL() ?? ""
    @State private var extensionBundleId: String = SharedBroadcastConfig.shared.extensionBundleIdentifier() ?? ""

    var body: some View {
        Form {
            Section(header: Text("RTMP")) {
                TextField("rtmp://server/app/streamKey", text: $rtmpURL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button("Save") {
                    SharedBroadcastConfig.shared.saveRTMPURL(rtmpURL)
                }
            }

            Section(header: Text("Broadcast Extension")) {
                TextField("Extension Bundle Identifier", text: $extensionBundleId)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button("Save") {
                    SharedBroadcastConfig.shared.saveExtensionBundleIdentifier(extensionBundleId)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}


