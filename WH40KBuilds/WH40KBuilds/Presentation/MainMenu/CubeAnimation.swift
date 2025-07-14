//
//  CubeAnimation.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import SwiftUI
import AVKit

struct CubeAnimation<Front: View, Side: View>: View {
    @Binding var showSide: Bool
    let front: Front
    let side:  Side
    
    @State private var θ: CGFloat = 0
    private let persp: CGFloat = 0.0017
    
    var body: some View {
        GeometryReader { geo in
            let w  = geo.size.width
            
            ZStack {
                front
                    .opacity(θ < 90 ? 1 : 0)
                    .rotation3DEffect(.degrees(Double(θ)),
                                      axis: (0,1,0),
                                      perspective: persp)
                    .offset(x: -w * θ / 90 / 2)
                
                side
                    .opacity(θ >= 0 ? 1 : 0)
                    .rotation3DEffect(.degrees(Double(θ) - 90),
                                      axis: (0,1,0),
                                      perspective: persp)
                    .offset(x:  w * (1 - θ / 90) / 2)
            }
            .clipped()
            .onChange(of: showSide) { _, toSide in
                animate(toSide)
            }
            .onAppear { θ = showSide ? 90 : 0 }
        }
    }
    
    private func animate(_ toSide: Bool) {
        withAnimation(.easeInOut(duration: 1.6)) { 
            θ = toSide ? 90 : 0
        }
    }
}
