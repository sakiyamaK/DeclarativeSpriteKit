//
//  ContentView.swift
//  DeclarativeSpriteKitDemo
//
//  Created by sakiyamaK on 2025/06/07.
//

import SwiftUI
import SpriteKit
import DeclarativeSpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            SpriteView(
                scene: GameScene(size: geometry.size).apply({ scene in
                    scene.scaleMode = .aspectFill
                }),
                options: [.ignoresSiblingOrder]
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .statusBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
