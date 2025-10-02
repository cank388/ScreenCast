RTMP broadcast (ReplayKit) - setup notes

1) Add App Group to both targets (App + Broadcast Upload Extension)
   - Example: group.com.example.screencast
   - Update appGroupIdentifier in `SharedBroadcastConfig`

2) Add HaishinKit via Swift Package Manager (if using RTMP)
   - Package URL: https://github.com/shogo4405/HaishinKit.swift
   - Link to Broadcast Upload Extension target

3) Microphone permission (main app `Info.plist`)
   - NSMicrophoneUsageDescription

4) Local Network permissions (for Chromecast discovery in main app)
   - NSLocalNetworkUsageDescription + NSBonjourServices already present

5) Preferred extension id
   - Save your extension bundle id in Settings screen or set default in `SharedBroadcastConfig`

6) Implement RTMP pipeline in `SampleHandler`
   - Replace placeholders with HaishinKit `RTMPConnection` + `RTMPStream` publish logic
   - Map `processSampleBuffer` video/audio to the stream

7) WebRTC option (low-latency alternative)
   - Use a WebRTC library (e.g. Google WebRTC M1 build) in extension
   - Send to SFU/MCU, play on TV browser or custom Cast receiver


