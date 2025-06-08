//
//  BlockBreakingGameOverScene.swift
//  DeclarativeSpriteKitDemo
//
//  Created by sakiyamaK on 2025/06/08.
//

import SpriteKit
import DeclarativeSpriteKit

class BlockBreakingGameOverScene: DeclarativeScene {

    override func sceneDidLoad() {
        super.sceneDidLoad()

        self.apply({ scene in
            scene.backgroundColor = SKColor.black
        }).addChildren {
            SKLabelNode().apply { label in
                label.text = "GAME OVER"
                label.fontName = "AvenirNext-Medium"
                label.fontSize = 70
                label.fontColor = SKColor.red
                label.position = CGPoint(x: frame.midX, y: frame.midY + 50)
                label.zPosition = 100
            }

            SKLabelNode().apply { label in
                label.text = "タップしてリスタート"
                label.fontName = "AvenirNext-Medium"
                label.fontSize = 30
                label.fontColor = SKColor.white
                label.position = CGPoint(x: frame.midX, y: frame.midY - 30)
                label.name = "restartButton"
                label.zPosition = 100
            }.tracking {[weak self] in
                self!.touchesBeganNodes
            } onChange: {[weak self] label, nodes in
                guard let self else { return }
                guard nodes.contains(label) else { return }

                self.view?.presentScene(
                    BlockBreakingGameHomeScene(size: size).apply { scene in
                        scene.scaleMode = .aspectFill
                    },
                    transition: SKTransition.crossFade(withDuration: 1.0)
                )
            }
        }
    }
}
