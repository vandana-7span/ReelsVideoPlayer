//
//  ActionButton.swift
//  ReeScroll
//
//  Created by Vandana Modi on 19/02/25.
//

import SwiftUI

/// A view that displays a set of action buttons for like, comment, share, and menu actions.
public struct ActionButton: View {
    // Action closures for each button
    var likeAction: () -> Void
    var commentAction: () -> Void
    var shareAction: () -> Void
    var menuAction: () -> Void
    
    // Text labels for each button
    var likeText: String
    var commentText: String
    var shareText: String

    /// Initializes a new instance of `ActionButton`.
    /// - Parameters:
    ///   - likeAction: Closure to execute when the like button is pressed.
    ///   - commentAction: Closure to execute when the comment button is pressed.
    ///   - shareAction: Closure to execute when the share button is pressed.
    ///   - menuAction: Closure to execute when the menu button is pressed.
    ///   - likeText: Text to display for the like button. Default is "100k".
    ///   - commentText: Text to display for the comment button. Default is "120".
    ///   - shareText: Text to display for the share button. Default is "".
    public init(
        likeAction: @escaping () -> Void,
        commentAction: @escaping () -> Void,
        shareAction: @escaping () -> Void,
        menuAction: @escaping () -> Void,
        likeText: String = "100k",
        commentText: String = "120",
        shareText: String = ""
    ) {
        self.likeAction = likeAction
        self.commentAction = commentAction
        self.shareAction = shareAction
        self.menuAction = menuAction
        self.likeText = likeText
        self.commentText = commentText
        self.shareText = shareText
    }

    public var body: some View {
        VStack(spacing: 25) {
            // Like button
            Button(action: likeAction) {
                VStack(spacing: 10) {
                    Image(systemName: "suit.heart")
                        .font(.title)
                    Text(likeText)
                        .font(.caption.bold())
                }
            }
            // Comment button
            Button(action: commentAction) {
                VStack(spacing: 10) {
                    Image(systemName: "bubble.right")
                        .font(.title)
                    Text(commentText)
                        .font(.caption.bold())
                }
            }
            // Share button
            Button(action: shareAction) {
                VStack(spacing: 10) {
                    Image(systemName: "paperplane")
                        .font(.title)
                    Text(shareText)
                        .font(.caption.bold())
                }
            }
            // Menu button
            Button(action: menuAction) {
                VStack(spacing: 20) {
                    Image("menu")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .rotationEffect(Angle(degrees: 90))
                }
            }
        }
    }
}
