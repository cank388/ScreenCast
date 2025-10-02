//
//  SampleHandler.swift
//  ScreenCastBroadcastUpload
//
//  Created by Assistant on 1.10.2025.
//

import ReplayKit
import AVFoundation
import os.log
#if canImport(HaishinKit)
import HaishinKit
import VideoToolbox
#endif

/// Basic broadcast upload sample handler.
/// Replace buffer handling with your uploader/encoder.
class SampleHandler: RPBroadcastSampleHandler {
    private var rtmpURL: String = ""
    private let log = OSLog(subsystem: "ScreenCastBroadcastUpload", category: "RTMP")
#if canImport(HaishinKit)
    private let rtmpConnection = RTMPConnection()
    private lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
#endif

    // Frame counters for debugging
    private var videoSampleCount: Int = 0
    private var audioAppSampleCount: Int = 0
    private var audioMicSampleCount: Int = 0
    private let logInterval: Int = 60 // log every N video frames

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // Read RTMP URL from shared App Group
        let appGroupId = "group.kalender.ScreenCast"
        os_log("Using App Group: %{public}@", log: log, type: .info, appGroupId)
        if let defaults = UserDefaults(suiteName: appGroupId), let url = defaults.string(forKey: "rtmp_url"), !url.isEmpty {
            rtmpURL = url
        }
        if rtmpURL.isEmpty {
            os_log("broadcastStarted but RTMP URL is EMPTY. Set it in app Settings.", log: log, type: .fault)
        } else {
            os_log("broadcastStarted, rtmpURL=%{public}@", log: log, type: .info, rtmpURL)
        }

        // Do not configure AVAudioSession in a Broadcast Upload Extension.
        // ReplayKit provides audio sample buffers directly; changing audio session here often causes -50 errors.

        // Setup RTMP pipeline
#if canImport(HaishinKit)
        // Observe RTMP connection events
        NotificationCenter.default.addObserver(self, selector: #selector(onRtmpStatus(_:)), name: .rtmpStatus, object: rtmpConnection)
        NotificationCenter.default.addObserver(self, selector: #selector(onRtmpError(_:)), name: .rtmpError, object: rtmpConnection)

        rtmpStream.captureSettings = [ .fps: 30 ]
        rtmpStream.videoSettings = [ .width: 720, .height: 1280, .bitrate: 2_000_000, .maxKeyFrameIntervalDuration: 2 ]
        rtmpStream.audioSettings = [ .sampleRate: 44_100 ]

        if let url = URL(string: rtmpURL), url.pathComponents.count >= 3 {
            var connectURL = url
            let streamKey = url.lastPathComponent
            connectURL.deleteLastPathComponent()
            os_log("Connecting to %{public}@, publishing %{public}@", log: log, type: .info, connectURL.absoluteString, streamKey)
            rtmpConnection.connect(connectURL.absoluteString)
            rtmpStream.publish(streamKey)
        } else {
            os_log("Connecting to %{public}@, publishing default 'live'", log: log, type: .info, rtmpURL)
            rtmpConnection.connect(rtmpURL)
            rtmpStream.publish("live")
        }
#else
        os_log("HaishinKit not linked. Skipping RTMP publish.", log: log, type: .fault)
#endif
    }

    override func broadcastPaused() {
        os_log("broadcastPaused", log: log, type: .info)
    }

    override func broadcastResumed() {
        os_log("broadcastResumed", log: log, type: .info)
    }

    override func broadcastFinished() {
        // Tear down your streaming pipeline
#if canImport(HaishinKit)
        rtmpStream.close()
        rtmpConnection.close()
        NotificationCenter.default.removeObserver(self, name: .rtmpStatus, object: rtmpConnection)
        NotificationCenter.default.removeObserver(self, name: .rtmpError, object: rtmpConnection)
#endif
        os_log("broadcastFinished", log: log, type: .info)
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
#if canImport(HaishinKit)
            rtmpStream.appendSampleBuffer(sampleBuffer, withType: .video)
#endif
            videoSampleCount += 1
            if videoSampleCount % logInterval == 0 {
                os_log("video=%{public}d, audioApp=%{public}d, audioMic=%{public}d", log: log, type: .debug, videoSampleCount, audioAppSampleCount, audioMicSampleCount)
            }
            break
        case .audioApp:
#if canImport(HaishinKit)
            rtmpStream.appendSampleBuffer(sampleBuffer, withType: .audio)
#endif
            audioAppSampleCount += 1
            break
        case .audioMic:
#if canImport(HaishinKit)
            rtmpStream.appendSampleBuffer(sampleBuffer, withType: .audio)
#endif
            audioMicSampleCount += 1
            break
        @unknown default:
            break
        }
    }

#if canImport(HaishinKit)
    @objc private func onRtmpStatus(_ notification: Notification) {
        guard let e = Event.from(notification) else { return }
        let data = e.data as? ASObject
        let code = data?["code"] as? String ?? ""
        os_log("RTMP status: %{public}@", log: log, type: .info, code)
    }

    @objc private func onRtmpError(_ notification: Notification) {
        guard let e = Event.from(notification) else { return }
        os_log("RTMP error: %{public}@", log: log, type: .error, String(describing: e))
    }
#endif
}


