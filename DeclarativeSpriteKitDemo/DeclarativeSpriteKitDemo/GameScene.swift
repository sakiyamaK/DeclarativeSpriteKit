
//
//  GameSceke.swift
//  DeclarativeSpriteKitDemo
//
//  Created by sakiyamaK on 2025/06/07.
//

import SpriteKit
import GameKit
import DeclarativeSpriteKit

@Observable
class Player {
    var position: CGPoint = .zero
}

class GameScene: DeclarativeScene {

    var player: Player = .init()
    @SKState var score: Int = 0

    override func didMove(to view: SKView) {

        let safeAreaTopInset = view.safeAreaInsets.top

        self.addChildren {
            SKSpriteNode()
                .apply({ sprite in
                    sprite.color = .blue
                    sprite.size = .init(width: 100, height: 100)
                    sprite.position = .init(x: self.frame.midX, y: self.frame.midY)
                })
                .tracking(useInitialValue: false){ [weak self] in
                    self!.player.position
                } onChange: { sprite, position in
                    sprite.run(.move(to: position, duration: 0.1))
                }

            SKLabelNode()
                .apply({ label in
                    label.verticalAlignmentMode = .top
                    label.fontColor = .blue
                    label.fontSize = 50
                    label.position = .init(x: self.frame.midX, y: self.frame.maxY - safeAreaTopInset)
                })
                .tracking {[weak self] in
                    self!.score.description
                } onChange: { label, value in
                    label.text = value
                }
        }.backgroundColor(
            .white
        ).touchesBegan {[weak self] touches, event in
            guard let self else { return }
            if let touchLocation = touches.first?.location(in: self) {
                self.player.position = touchLocation
            }
            self.score += 1
        }
    }
}
