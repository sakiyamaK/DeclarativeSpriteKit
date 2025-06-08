//
//  BlockBreakingGameHomeScene.swift
//  DeclarativeSpriteKitDemo
//
//  Created by Your Name on 2025/06/07.
//

import SpriteKit
import DeclarativeSpriteKit

final class BlockBreakingGameHomeScene: DeclarativeScene {

    @SKState private var isPresented: Bool = false

    override func sceneDidLoad() {
        super.sceneDidLoad()

        self.apply({ scene in
            scene.backgroundColor = .darkGray
        }).addChildren {
            SKLabelNode()
                .apply { label in
                    label.text = "ブロック崩し"
                    label.fontName = "AvenirNext-Bold"
                    label.fontSize = 40
                    label.fontColor = SKColor.white
                    label.position = CGPoint(x: frame.midX, y: frame.midY + 50)
                }

            SKLabelNode()
                .apply { label in
                    label.text = "START"
                    label.fontName = "AvenirNext-Bold"
                    label.fontSize = 50
                    label.fontColor = SKColor.green
                    label.position = CGPoint(x: frame.midX, y: frame.midY - 50)
                }
                .tracking {[weak self] in
                    self!.touchesBeganNodes
                } onChange: {[weak self] label, nodes in
                    guard let self else { return }
                    guard nodes.contains(label) else { return }
                    self.isPresented = true
                }
        }.tracking {[weak self] in
            self!.isPresented
        } onChange: { [weak self] scene, isPresented in
            guard let self else { return }
            guard isPresented else { return }
            // ゲームプレイシーンへ遷移
            self.view?.presentScene(
                BlockBreakingGamePlayScene(size: self.size).apply { scene in
                    scene.scaleMode = .aspectFill
                },
                transition: SKTransition.crossFade(withDuration: 0.8)
            )
        }

    }
}
