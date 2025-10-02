//
//  ContentView.swift
//  ScreenCast
//
//  Created by Can Kalender on 1.10.2025.
//

import SwiftUI
import AVKit
import ReplayKit
import Combine

struct ContentView: View {
    @State private var showCastOptions: Bool = false
    @State private var showChromecastInfo: Bool = false
    @State private var rtmpURLString: String = SharedBroadcastConfig.shared.readRTMPURL() ?? "rtmp://192.168.1.102:1935/live/stream"
    @State private var isCastConnected: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text("ScreenCast")
                .font(.largeTitle)
                .bold()

            // AirPlay route picker (works with Android TV AirPlay receivers like AirScreen)
            VStack(spacing: 8) {
                Text("AirPlay")
                    .font(.headline)
                AirPlayRoutePicker()
                    .frame(height: 44)
            }

            // ReplayKit broadcast picker (requires a broadcast upload extension on device)
            VStack(spacing: 8) {
                Text("Ekranı Yayınla")
                    .font(.headline)
                BroadcastPicker()
                    .frame(height: 60)
                HStack(spacing: 8) {
                    TextField("RTMP URL", text: $rtmpURLString)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("Kaydet") {
                        SharedBroadcastConfig.shared.saveRTMPURL(rtmpURLString)
                    }
                    .buttonStyle(.bordered)
                }
            }

            // Chromecast stub: shows instructions unless Google Cast SDK integration is added
            VStack(spacing: 8) {
                Text("Chromecast")
                    .font(.headline)
                CastButton()
                    .frame(height: 44)
                Button {
                    CastMediaController.shared.playSampleMedia()
                } label: {
                    HStack {
                        Image(systemName: "tv")
                        Text("Ekranı Chromecast'e Gönder")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!isCastConnected)
            }

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Ayarlar") {
                    SettingsView()
                }
            }
        }
        .onAppear {
            updateCastConnectionState()
            // Update state every second to catch connection changes
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                updateCastConnectionState()
            }
        }
    }
    
    private func updateCastConnectionState() {
        isCastConnected = CastMediaController.shared.isConnected
    }
}

// MARK: - AirPlay UIKit bridge
struct AirPlayRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = true
        if #available(iOS 13.0, *) {
            view.activeTintColor = UIColor.label
            view.tintColor = UIColor.systemBlue
        }
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        // No-op
    }
}

// MARK: - ReplayKit broadcast picker bridge
struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = SharedBroadcastConfig.shared.extensionBundleIdentifier()
        if let button = picker.subviews.first(where: { $0 is UIButton }) as? UIButton {
            let image = UIImage(systemName: "dot.radiowaves.left.and.right")
            button.setImage(image, for: .normal)
            button.tintColor = .systemRed
        }
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {
        // No-op
    }
}

#Preview {
    ContentView()
}

