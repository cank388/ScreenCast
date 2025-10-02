//
//  CastMediaController.swift
//  ScreenCast
//
//  Created by Assistant on 1.10.2025.
//

import Foundation
import GoogleCast

#if canImport(GoogleCast)

/// Simple helper to load and play media on a connected Cast session.
final class CastMediaController: NSObject {
    static let shared = CastMediaController()

    private override init() { }

    var isConnected: Bool {
        return GCKCastContext.sharedInstance().sessionManager.currentSession != nil
    }

    /// Loads and plays your live screen cast on Chromecast.
    func playSampleMedia() {
        guard isConnected else {
            print("No active Cast session - please connect to Chromecast first")
            return
        }
        
        guard let remoteClient = (GCKCastContext.sharedInstance().sessionManager.currentSession as? GCKSession)?.remoteMediaClient else { 
            print("No active Cast session")
            return 
        }

        // Default local HLS URL - replace with your Mac's IP
        let urlString = "http://192.168.1.102:8080/live/stream.m3u8"
        guard let url = URL(string: urlString) else { 
            print("Invalid URL: \(urlString)")
            return 
        }

        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString("Screen Cast Live", forKey: kGCKMetadataKeyTitle)
        metadata.setString("Live screen sharing", forKey: kGCKMetadataKeySubtitle)

        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url)
        mediaInfoBuilder.contentType = "application/vnd.apple.mpegurl"
        mediaInfoBuilder.streamType = .live
        mediaInfoBuilder.metadata = metadata

        let mediaInfo = mediaInfoBuilder.build()
        let options = GCKMediaLoadOptions()
        options.autoplay = true

        print("Loading media: \(urlString)")
        remoteClient.loadMedia(mediaInfo, with: options)
    }
}
#else
final class CastMediaController: NSObject {
    static let shared = CastMediaController()
    private override init() { }
    var isConnected: Bool { false }
    func playSampleMedia() { }
}
#endif


