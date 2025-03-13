![ReelsVideoPlayer Demo](ReelVideoPlayer-4.gif)

# ReelsVideoPlayer Swift Package

ReelsVideoPlayer is a customizable Swift package for implementing an Instagram Reels-style video player in SwiftUI. It supports smooth infinite scrolling, video playback optimization, interactive progress sliders, and customizable overlays.

## Features

- 📹 **Smooth Video Playback** with efficient memory management
- 🔄 **Infinite Scrolling** for seamless content consumption
- 🎛 **Customizable UI** with flexible overlays and controls
- 🎚 **Interactive Progress Slider** to seek videos easily
- 🔇 **Mute Button Support** for toggling audio
- 🚀 **Optimized Performance** using preloading and buffering

---

## Installation

### Swift Package Manager (SPM)

1. Open your **Xcode project**
2. Go to **File** → **Add Packages**
3. Enter the repository URL: `https://github.com/vandana-7span/ReelsVideoPlayer.git`
4. Select the latest version and click **Add Package**

---

## Usage

### Basic Implementation

```swift
import ReelsVideoPlayer
import SwiftUI

struct ContentView: View {
    var reelData: [Reel] = []
    
    init() {
        reelData = MediaFileJson.map { mediaFile in
            Reel(
                url: mediaFile.url,
                likeText: mediaFile.likeText,
                commentText: mediaFile.commentText,
                shareText: mediaFile.shareText,
                profileImage: mediaFile.profileImage,
                profileName: mediaFile.profileName,
                captionText: mediaFile.captionText,
                albumImage: mediaFile.albumImage
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ReelsView(
                    reels: reelData,
                    batchSize: 20,
                    bufferRange: 3,
                    preferredForwardBufferDuration: 5.0,
                    overlayView: { showDefaultOverlay ? EmptyView() : CustomOverlayView() },
                    likeAction: { print("Liked") },
                    commentAction: { print("Commented") },
                    shareAction: { print("Shared") },
                    menuAction: { print("Menu opened") },
                    profileFollowAction: { print("Followed") },
                    profileImageAction: { print("Profile image clicked") },
                    profileNameAction: { print("Profile name clicked") },
                    albumImageAction: { print("Bottom action") },
                    loadingText: "Loading...",
                    showDefaultOverlay: true // Toggle between default and custom overlay
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Instagram-style bottom navigation bar
            HStack(spacing: 0) {
                Spacer()
                Image(systemName: "house.fill").frame(maxWidth: .infinity)
                Image(systemName: "magnifyingglass").frame(maxWidth: .infinity)
                Image(systemName: "plus.app.fill").frame(maxWidth: .infinity)
                Image(systemName: "heart.fill").frame(maxWidth: .infinity)
                Image(systemName: "person.fill").frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(height: 50)
            .background(Color.black)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
```

---
## Customization

### Overlay Customization

You can provide a custom overlay by setting `showDefaultOverlay = false` and passing a custom SwiftUI view, or use the default overlay by setting `showDefaultOverlay = true`.

```swift
struct CustomOverlayView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text("Custom Overlay Title")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Custom overlay subtitle")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.7))
        }
    }
}
```

Then use it in `ReelsView`:

```swift
ReelsView(
    reels: reelData,
    batchSize: 50,
    bufferRange: 3,
    preferredForwardBufferDuration: 5.0,
    overlayView: { CustomOverlayView() }
)
```

### Adjusting Buffering

Change `preferredForwardBufferDuration` to control video preloading:

```swift
preferredForwardBufferDuration: 8.0  // Adjust buffer duration
```
---

## Troubleshooting

### 2️⃣ Videos Not Playing Smoothly?

✔ Try reducing `preferredForwardBufferDuration`. ✔ Optimize preloading and memory usage.

---

## License

This package is open-source and available under the MIT License.

---

## Contributing

Feel free to submit pull requests or open issues for feature requests or bug fixes!

---

## Contact

For support or feature requests, reach out at [vandana@7span.com](mailto\:vandana@7span.com).

