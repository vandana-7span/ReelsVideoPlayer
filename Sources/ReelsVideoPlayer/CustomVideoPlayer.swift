//
//  CustomVideoPlayer.swift
//  ReeScroll
//
//  Created by Vandana Modi on 11/03/25.
//

import SwiftUI
import AVFoundation
import AVKit

/// A custom video player using `AVPlayerViewController` that integrates with SwiftUI.
struct CustomVideoPlayer: UIViewControllerRepresentable {
    
    /// The AVPlayer instance that will be used for video playback.
    var player: AVPlayer
    
    /// Creates a coordinator to handle delegate methods and notifications.
    /// - Returns: A new `Coordinator` instance.
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    /// Creates the `AVPlayerViewController` to be used in the view.
    /// - Parameter context: The context in which the view controller is created.
    /// - Returns: A configured `AVPlayerViewController` instance.
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        vc.videoGravity = .resizeAspectFill
        vc.player?.actionAtItemEnd = .none
        
        // Add observer to restart playback when the video reaches the end.
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.restartPlayback),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        return vc
    }
    
    /// Updates the view controller with new data.
    /// - Parameters:
    ///   - uiViewController: The view controller to update.
    ///   - context: The context in which the update occurs.
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No updates needed for now.
    }
    
    /// A coordinator to handle delegate methods and notifications.
    class Coordinator: NSObject {
        var parent: CustomVideoPlayer
        
        /// Initializes a new Coordinator instance.
        /// - Parameter parent: The parent `CustomVideoPlayer` instance.
        init(parent: CustomVideoPlayer) {
            self.parent = parent
        }
        
        /// Restarts video playback from the beginning.
        @objc func restartPlayback() {
            parent.player.seek(to: .zero)
        }
    }
}
