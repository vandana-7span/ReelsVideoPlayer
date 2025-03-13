//
//  Reel.swift
//  Instagram
//
// Created by Vandana on 28/01/25.
//

import Foundation
import AVKit
import SwiftUI

public struct Reel: Identifiable {
    public var id: String = UUID().uuidString
    public var player: AVPlayer? =  nil
    public var url: String
    public var  likeText: String?
    public var  commentText: String?
    public var  shareText: String?
    public var  profileImage: String?
    public var  profileName: String?
    public var  captionText: String?
    public var  albumImage: String?
    
    public init(id: String = UUID().uuidString, url: String, player: AVPlayer? = nil, likeText: String?, commentText: String?,shareText: String?,profileImage: String? , profileName: String? ,captionText: String? ,albumImage: String?) {
        self.id = id
        self.url = url
        self.player = player
        self.likeText = likeText
        self.commentText = commentText
        self.shareText = shareText
        self.profileImage = profileImage
        self.profileName = profileName
        self.captionText =   captionText
        self.albumImage = albumImage
    }
}

