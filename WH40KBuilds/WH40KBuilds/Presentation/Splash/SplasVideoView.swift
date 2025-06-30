//
//  SplasView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 29/6/25.
//

import SwiftUI
import AVKit

struct SplashVideoView: View {
    @State private var player = AVQueuePlayer()
    @State private var looper: AVPlayerLooper?

    var body: some View {
        VideoPlayer(player: player)
            .scaledToFit()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .center)
            .background(Color.black)                    
            .ignoresSafeArea()
            .onAppear {
                guard
                    let url = Bundle.main.url(forResource: "splash", withExtension: "mp4")
                else {
                    print("❌ splash.mp4 no encontrado")
                    return
                }
                let item = AVPlayerItem(url: url)
                looper = AVPlayerLooper(player: player, templateItem: item)
                player.isMuted = true
                player.play()
            }
            .onDisappear {
                player.pause()
                looper = nil
            }
    }
}

