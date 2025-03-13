//
//  ReelView.swift
//  ReeScroll
//
//  Created by Vandana Modi on 19/02/25.
//

import SwiftUI
import AVKit

/// A view that displays a list of reels with video playback functionality.
public struct ReelsView<Overlay: View>: View {
    // State properties to manage the current reel, loaded reels, and other states.
    @State private var currentReel = ""
    @State private var loadedReels: [Reel] = []
    @State private var allReels: [Reel] = []
    @State private var isLoading = false
    @State private var disableScrolling = false
    @State private var currentIndex: Int = 0
    @State private var playerProgress: Double = 0.0
    @State private var isMuted = false
    @State private var volumeAnimation = false
    @State private var isDraggingSlider = false
    @State private var isTextExpanded = false

    // Configuration properties passed via the initializer.
    private var batchSize: Int
    private var bufferRange: Int
    private var preferredForwardBufferDuration: TimeInterval
    private var overlayView: () -> Overlay
    private var likeAction: () -> Void
    private var commentAction: () -> Void
    private var shareAction: () -> Void
    private var menuAction: () -> Void
    private var profileFollowAction: () -> Void
    private var profileImageAction: () -> Void
    private var profileNameAction: () -> Void
    private var albumImageAction: () -> Void
    private var loadingText: String
    private var showDefaultOverlay: Bool  // ✅ New flag to enable both overlays
    
    // Initializer for ReelsView.
    public init(
        reels: [Reel],
        batchSize: Int = 10,
        bufferRange: Int = 2,
        preferredForwardBufferDuration: TimeInterval = 3.0,
        overlayView: @escaping () -> Overlay = { EmptyView() },
        likeAction: @escaping () -> Void = {},
        commentAction: @escaping () -> Void = {},
        shareAction: @escaping () -> Void = {},
        menuAction: @escaping () -> Void = {},
        profileFollowAction: @escaping () -> Void = {},
        profileImageAction: @escaping () -> Void = {},
        profileNameAction: @escaping () -> Void = {},
        albumImageAction: @escaping () -> Void = {},
        loadingText: String = "",
        showDefaultOverlay: Bool = true  // ✅ Allows enabling both overlays
    ) {
        // Map the reels to create Reel objects with AVPlayer instances.
        let reelItems = reels.map { data -> Reel in
            let videoURL: URL?

            if let localPath = Bundle.main.url(forResource: data.url, withExtension: "mp4") {
                videoURL = localPath
            } else {
                videoURL = URL(string: data.url) // Assumes URL is remote if not found locally
            }

            let player = videoURL != nil ? AVPlayer(url: videoURL!) : nil // Avoid force unwrap if URL is invalid

            return Reel(
                id: data.id,
                url: data.url,
                player: player,
                likeText: data.likeText,
                commentText: data.commentText,
                shareText: data.shareText,
                profileImage: data.profileImage,
                profileName: data.profileName,
                captionText: data.captionText,
                albumImage: data.albumImage
                
            )
        }

        _allReels = State(initialValue: reelItems)
        _loadedReels = State(initialValue: Array(reelItems.prefix(batchSize)))

        self.batchSize = batchSize
        self.bufferRange = bufferRange
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
        self.overlayView = overlayView
        self.likeAction = likeAction
        self.commentAction = commentAction
        self.shareAction = shareAction
        self.menuAction = menuAction
        self.profileFollowAction = profileFollowAction
        self.profileImageAction = profileImageAction
        self.profileNameAction = profileNameAction
        self.albumImageAction = albumImageAction
        self.loadingText = loadingText
        self.showDefaultOverlay = showDefaultOverlay
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                // TabView to display the reels.
                TabView(selection: $currentReel) {
                    ForEach($loadedReels) { $reel in
                        ReelsPlayer<Overlay>(
                            reel: $reel,
                            currentReel: $currentReel,
                            playerProgress: $playerProgress,
                            preferredForwardBufferDuration: preferredForwardBufferDuration,
                            overlayView: overlayView
                        )
                        .frame(width: proxy.size.width)
                        .rotationEffect(Angle(degrees: -90))
                        .ignoresSafeArea(.all, edges: .top)
                        .tag(reel.id)
                        .onAppear { handleOnAppear(for: reel) }
                        .onDisappear { handleOnDisappear(for: reel) }
                    }
                }
                .rotationEffect(Angle(degrees: 90))
                .frame(width: proxy.size.height)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: proxy.size.width)
                .disabled(disableScrolling)
                .onChange(of: currentReel) { oldValue, newValue in
                    if let index = loadedReels.firstIndex(where: { $0.id == newValue }) {
                        currentIndex = index
                    }
                }

                // Loading indicator.
                if isLoading {
                    VStack {
                        ProgressView(loadingText)
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
                    .allowsHitTesting(false)  // Ensures touch passes through
                }

                // Overlay view.
                if showDefaultOverlay {
                    VStack {
                        defaultHeaderView
                        defaultBottomControls
                    }
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding()
                }
                

                // Progress slider.
                VStack {
                    Spacer()
                    defaultProgressSlider()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                defaultMuteButton
                // Overlay view on top of the video.
                overlayView()
            }
            .onTapGesture {
                // Toggle mute when the view is tapped.
                if let reel = loadedReels.first(where: { $0.id == currentReel }) {
                    toggleMute(for: reel.player!)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .background(.black)
        .onAppear {
            currentReel = loadedReels.first?.id ?? ""
        }
    }

    // Handle the appearance of a reel.
    private func handleOnAppear(for reel: Reel) {
        let index = loadedReels.firstIndex { $0.id == reel.id } ?? 0

        Task { @MainActor in
            preloadVideo(for: reel) // ✅ Now runs safely on the main thread
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if currentReel == reel.id {
                reel.player?.play()
            }
        }
        
        if index >= loadedReels.count - 1 {
            loadMoreReels()
        }
        
        cleanUpMemory(for: index)
    }


    // Preload the video for a reel.
    private func preloadVideo(for reel: Reel) {
        let path = Bundle.main.path(forResource: reel.url, ofType: "mp4") ?? ""
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = preferredForwardBufferDuration
        DispatchQueue.main.async {
            if reel.player?.currentItem == nil {
                reel.player?.replaceCurrentItem(with: playerItem)
            }
        }
    }

    // Handle the disappearance of a reel.
    private func handleOnDisappear(for reel: Reel) {
        reel.player?.pause()
    }

    // Load more reels when reaching the end of the currently loaded reels.
    private func loadMoreReels() {
        guard !isLoading, loadedReels.count < allReels.count else { return }
        
        isLoading = true
        disableScrolling = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            let nextBatch = allReels[loadedReels.count..<min(loadedReels.count + batchSize, allReels.count)]
            
            await MainActor.run {
                loadedReels.append(contentsOf: nextBatch)
                isLoading = false
                disableScrolling = false
            }
        }
    }


    // Clean up memory by pausing and releasing players that are out of the buffer range.
    private func cleanUpMemory(for currentIndex: Int) {
        let safeRange = max(0, currentIndex - bufferRange)...min(loadedReels.count - 1, currentIndex + bufferRange)
        for (index, reel) in loadedReels.enumerated() {
            if !safeRange.contains(index) {
                reel.player?.pause()
                if !safeRange.contains(index) {
                    reel.player?.replaceCurrentItem(with: nil)
                }
            }
        }
    }

    // Default header view with profile information and action buttons.
    private var defaultHeaderView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                profileInfo
            }
            Spacer(minLength: 20)
            VStack {
                ActionButton(
                    likeAction: likeAction,
                    commentAction: commentAction,
                    shareAction: shareAction,
                    menuAction: menuAction,
                    likeText: loadedReels[currentIndex].likeText ?? "",
                    commentText: loadedReels[currentIndex].commentText ?? "",
                    shareText: loadedReels[currentIndex].shareText ?? ""
                )
            }
            .frame(width: 40)
            .padding(.leading, -20)
        }
    }

    // Profile information view.
    private var profileInfo: some View {
        HStack(spacing: 15) {
            Button(action: profileImageAction) {
                Image(loadedReels[currentIndex].profileImage ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            }
            Button(action: profileNameAction) {
                Text(loadedReels[currentIndex].profileName ?? "")
                    .font(.callout.bold())
            }
            Button(action: profileFollowAction) {
                Text("Follow")
                    .font(.callout.bold())
            }
        }
    }

    // Default bottom controls including caption and album image.
    private var defaultBottomControls: some View {
        VStack {
            HStack {
                Button(action: { isTextExpanded.toggle() }) {
                    Text(loadedReels[currentIndex].captionText ?? "")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(isTextExpanded ? nil : 1)
                }
                Spacer(minLength: 20)
                Image(loadedReels[currentIndex].albumImage ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 28, height: 28)
                    .cornerRadius(6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white, lineWidth: 3)
                    )
                    .offset(x: -5)
                    .onTapGesture {
                        albumImageAction()
                    }
            }
        }
    }

    // Default progress slider.
    private func defaultProgressSlider() -> some View {
        CustomSlider(value: Binding(
            get: { Float(playerProgress) },
            set: { newValue in
                playerProgress = Double(newValue)
                if let reel = loadedReels.first(where: { $0.id == currentReel }) {
                    reel.player?.seek(to: CMTime(seconds: reel.player!.currentItem!.duration.seconds * playerProgress, preferredTimescale: 600))
                }
            }
        ))
    }

    // Toggle mute for the player's audio.
    private func toggleMute(for player: AVPlayer) {
        if volumeAnimation { return }
        isMuted.toggle()
        player.isMuted = isMuted
        withAnimation { volumeAnimation.toggle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { volumeAnimation.toggle() }
        }
    }

    // Default mute button.
    private var defaultMuteButton: some View {
        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
            .font(.title)
            .foregroundColor(.secondary)
            .padding()
            .background(Color.secondary.opacity(0.7))
            .clipShape(Circle())
            .opacity(volumeAnimation ? 1 : 0)
    }
}


