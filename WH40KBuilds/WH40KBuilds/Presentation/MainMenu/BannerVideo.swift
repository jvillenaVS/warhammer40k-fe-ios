//
//  BannerVideo.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import SwiftUI
import _AVKit_SwiftUI

struct BannerVideo: View {
    let player: AVPlayer

    var body: some View {
        VideoPlayer(player: player)
            .frame(height: 220)
            .cornerRadius(12)
            .onAppear {
                player.play()
                player.isMuted = true
                player.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                       object: player.currentItem,
                                                       queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
            }
            .onDisappear { player.pause() }
            .allowsHitTesting(false)
    }
}
