//
//  ReelPlayer.swift
//  ReeScroll
//
//  Created by Vandana Modi on 19/02/25.
//

import SwiftUI
import AVFoundation
import AVKit

/// A view that displays a single reel with video playback functionality.
public struct ReelsPlayer<Overlay: View>: View {
    @Binding var reel: Reel
    @Binding var currentReel: String
    @Binding var playerProgress: Double

    private var preferredForwardBufferDuration: TimeInterval
    private var overlayView: () -> Overlay

    /// Initializes a new instance of `ReelsPlayer`.
    /// - Parameters:
    ///   - reel: A binding to the current reel.
    ///   - currentReel: A binding to the current reel's ID.
    ///   - playerProgress: A binding to the player's progress.
    ///   - preferredForwardBufferDuration: The preferred forward buffer duration for the player.
    ///   - overlayView: A closure that returns the overlay view to be displayed on top of the video.
    public init(
        reel: Binding<Reel>,
        currentReel: Binding<String>,
        playerProgress: Binding<Double>,
        preferredForwardBufferDuration: TimeInterval,
        overlayView: @escaping () -> Overlay = { EmptyView() }
    ) {
        self._reel = reel
        self._currentReel = currentReel
        self._playerProgress = playerProgress
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
        self.overlayView = overlayView
    }

    public var body: some View {
        ZStack {
            // Check if the reel has a player.
            if let player = reel.player {
                // Manage video playback based on the reel's visibility.
                GeometryReader { proxy -> Color in
                    let minY = proxy.frame(in: .global).minY
                    let size = proxy.size
                    DispatchQueue.main.async {
                        manageVideoPlayback(player, minY, size)
                    }
                    return Color.clear
                }
                // Custom video player view.
                CustomVideoPlayer(player: player)
                    .onAppear {
                        preparePlayer(for: player)
                    }
                    .onDisappear {
                        player.pause()
                    }
            }
            // Overlay view on top of the video.
           // overlayView()
        }
    }

    /// Manages the video playback based on the visibility of the reel.
    /// - Parameters:
    ///   - player: The AVPlayer instance for the reel.
    ///   - minY: The minimum Y position of the reel in the global coordinate space.
    ///   - size: The size of the reel view.
    private func manageVideoPlayback(_ player: AVPlayer, _ minY: CGFloat, _ size: CGSize) {
        let isVisible = abs(minY) < size.height / 2 && currentReel == reel.id
        if isVisible {
            player.play()
        } else {
            player.pause()
        }
    }

    /// Prepares the player for playback by adding a periodic time observer.
    /// - Parameter player: The AVPlayer instance for the reel.
    private func preparePlayer(for player: AVPlayer) {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }

            DispatchQueue.main.async {
                self.playerProgress = time.seconds / duration
            }
        }
    }

    /// Seeks the player to a specific progress.
    /// - Parameter progress: The target progress to seek to.
    public func seek(to progress: Double) {
        if let duration = reel.player?.currentItem?.duration.seconds {
            let targetTime = CMTime(seconds: duration * progress, preferredTimescale: 600)
            reel.player?.seek(to: targetTime)
        }
    }
}
