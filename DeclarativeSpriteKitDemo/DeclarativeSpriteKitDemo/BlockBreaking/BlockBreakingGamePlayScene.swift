//
//  BlockBreakingGamePlayScene.swift
//  DeclarativeSpriteKitDemo
//
//  Created by sakiyamaK on 2025/06/08.
//

import SpriteKit
import GameplayKit
import DeclarativeSpriteKit

@Observable
class BlockBreakingGamePlaySceneModel: AnyObject {

    enum GameState {
        case ready
        case playing
        case gameOver
        case gameClear
    }

    var gameState: GameState = .ready
    var paddlePositionX: CGFloat = 0

    func createBlocks(frame: CGRect) -> [SKShapeNode] {

        let blockWidth: CGFloat = 60
        let horizontalPadding: CGFloat = 10
        let blockHeight: CGFloat = 20
        let verticalPadding: CGFloat = 10

        let numRows = 3

        let blocksPerRow = Int((frame.width - horizontalPadding * 2) / (blockWidth + horizontalPadding))
        let startX = frame.minX + horizontalPadding + blockWidth / 2
        let startY = frame.maxY - 100 // 画面上部から100ポイント下

        return (0..<numRows).compactMap { row in
            (0..<blocksPerRow).compactMap { col in
                CGPoint(
                    x: startX + CGFloat(col) * (blockWidth + horizontalPadding),
                    y: startY - CGFloat(row) * (blockHeight + verticalPadding)
                )
            }.compactMap { position in
                SKShapeNode(rectOf: CGSize(width: blockWidth, height: blockHeight), cornerRadius: 3).apply { block in
                    block.position = position
                    // 行によって色を変える
                    block.fillColor = SKColor(hue: CGFloat(row) / CGFloat(numRows), saturation: 0.8, brightness: 0.9, alpha: 1.0)
                    block.strokeColor = .clear
                    block.name = "block" // 衝突検出で識別するために名前を付ける
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size).apply({ physicsBody in
                        physicsBody.isDynamic = false // 動かない
                        physicsBody.affectedByGravity = false
                        physicsBody.friction = 0
                        physicsBody.restitution = 1.0
                        physicsBody.categoryBitMask = BlockBreakingPhysicsCategory.Block
                        physicsBody.collisionBitMask = BlockBreakingPhysicsCategory.Ball // ボールとのみ衝突
                    })
                }
            }
        }.flatMap { $0 }
    }
}

class BlockBreakingGamePlayScene: DeclarativeScene {

    private let sceneModel = BlockBreakingGamePlaySceneModel()

    // MARK: - Game Elements
    private let ball = SKShapeNode(circleOfRadius: 10)
    private let paddle = SKShapeNode(rectOf: CGSize(width: 80, height: 20), cornerRadius: 5)
    private(set) var blocks: [SKShapeNode] = [] // ブロックを管理する配列

    override func sceneDidLoad() {
        super.sceneDidLoad()

        self.apply { scene in
            scene.blocks = scene.sceneModel.createBlocks(frame: scene.frame)
            // 物理エンジンの設定
            scene.physicsWorld.gravity = .zero // 重力なし
            // 物理境界線を設定 (上下左右の壁)
            scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame).apply({ physicsBody in
                physicsBody.friction = 0 // 摩擦なし
                physicsBody.restitution = 1.0 // 反発係数1.0 (完全に跳ね返る)
                physicsBody.categoryBitMask = BlockBreakingPhysicsCategory.Wall
                physicsBody.contactTestBitMask = BlockBreakingPhysicsCategory.Ball // ボールとの衝突を検出
            })
            scene.backgroundColor = .black
        }.touchesBegan {[weak self] touches, event in
            guard let self else { return }
            // ゲームがまだ始まっていない場合のみ、ボールを発射
            if self.sceneModel.gameState == .ready {
                self.sceneModel.gameState = .playing
            }
            self.movePaddle(touches)
        }.touchesMoved { [weak self] touches, event in
            guard let self else { return }
            self.movePaddle(touches)
        }.didBeginContact({[weak self] contact in
            guard let self else { return }
            let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

            if collision == (BlockBreakingPhysicsCategory.Ball | BlockBreakingPhysicsCategory.Block) {
                // ボールとブロックの衝突
                let blockNode = (contact.bodyA.categoryBitMask == BlockBreakingPhysicsCategory.Block) ? contact.bodyA.node : contact.bodyB.node
                blockNode?.removeFromParent() // ブロックを削除

                // 全てのブロックがなくなったらゲームクリア（オプション）
                if self.blocks.allSatisfy({ $0.parent == nil }) { // 全てのブロックがシーンから削除されたか確認
                    self.sceneModel.gameState = .gameClear
                }
            } else if collision == (BlockBreakingPhysicsCategory.Ball | BlockBreakingPhysicsCategory.Bottom) {
                // ボールとボトムラインの衝突（ゲームオーバー）
                self.sceneModel.gameState = .gameOver
            }
        }).tracking {
            self.sceneModel.gameState
        } onChange: {[weak self] scene, gameState in
            guard let self else { return }
            switch gameState {
            case .ready:
                self.addChildren {
                    SKNode().apply { node in
                        // ゲームオーバー判定用の見えない下部ライン
                        let bottomRect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 1)
                        node.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
                        node.physicsBody?.isDynamic = false // 動かない
                        node.physicsBody?.categoryBitMask = BlockBreakingPhysicsCategory.Bottom
                        node.physicsBody?.contactTestBitMask = BlockBreakingPhysicsCategory.Ball //
                    }

                    self.paddle.apply {[weak self] paddle in
                        guard let self else { return }
                        paddle.fillColor = .cyan
                        paddle.strokeColor = .clear
                        paddle.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 50) // 画面下部から50ポイント上

                        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.frame.size)
                        paddle.physicsBody?.isDynamic = false // 動かない（ユーザー操作で動かすため）
                        paddle.physicsBody?.affectedByGravity = false
                        paddle.physicsBody?.friction = 0
                        paddle.physicsBody?.restitution = 1.0
                        paddle.physicsBody?.categoryBitMask = BlockBreakingPhysicsCategory.Paddle
                        paddle.physicsBody?.collisionBitMask = BlockBreakingPhysicsCategory.Ball //ボールとのみ衝突
                    }.tracking(useInitialValue: false) {
                        self.sceneModel.paddlePositionX
                    } onChange: { paddle, paddlePositionX in
                        paddle.position.x = paddlePositionX
                    }

                    self.ball.apply({[weak self] ball in
                        guard let self else { return }
                        let radius: CGFloat = self.ball.frame.height/2
                        ball.fillColor = .white
                        ball.strokeColor = .clear
                        // ボールの初期位置をパドルの少し上に設定
                        ball.position = CGPoint(
                            x: frame.midX,
                            y: self.paddle.position.y + self.paddle.frame.height / 2 + radius + 5
                        )

                        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
                        ball.physicsBody?.isDynamic = true // 物理演算の影響を受ける
                        ball.physicsBody?.affectedByGravity = false // 重力の影響を受けない
                        ball.physicsBody?.friction = 0 // 摩擦なし
                        ball.physicsBody?.restitution = 1.0 // 完全な反発
                        ball.physicsBody?.linearDamping = 0 // 空気抵抗なし
                        ball.physicsBody?.allowsRotation = false // 回転しない

                        ball.physicsBody?.categoryBitMask = BlockBreakingPhysicsCategory.Ball
                        // ボールが衝突を検出したい対象を設定
                        ball.physicsBody?.contactTestBitMask = BlockBreakingPhysicsCategory.Paddle | BlockBreakingPhysicsCategory.Block | BlockBreakingPhysicsCategory.Wall | BlockBreakingPhysicsCategory.Bottom
                        ball.physicsBody?.collisionBitMask = BlockBreakingPhysicsCategory.Paddle | BlockBreakingPhysicsCategory.Block | BlockBreakingPhysicsCategory.Wall
                    }).tracking {
                        self.sceneModel.gameState
                    } onChange: { ball, gameState in
                        switch gameState {
                        case .ready:
                            break
                        case .playing:
                            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10)) // 上方向へボールを発射
                        case .gameOver, .gameClear:
                            ball.physicsBody?.velocity = .zero
                            ball.removeFromParent()
                        }
                    }

                    self.blocks

                    SKLabelNode().apply {[weak self] label in
                        guard let self else { return }
                        label.text = "画面をタップしてボールを発射"
                        label.fontName = "AvenirNext-Bold"
                        label.fontSize = 30
                        label.fontColor = SKColor.lightGray
                        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                        label.name = "tapToStartLabel"
                    }.tracking {
                        self.sceneModel.gameState
                    } onChange: { label, gameState in
                        if gameState == .playing {
                            label.removeFromParent()
                        }
                    }
                }
            case .gameClear:
                scene.addChildren {
                    SKLabelNode().apply {[weak self] label in
                        guard let self else { return }
                        label.text = "GAME CLEAR!"
                        label.fontName = "AvenirNext-Bold"
                        label.fontSize = 70
                        label.fontColor = .yellow
                        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
                        label.zPosition = 100
                    }

                    SKLabelNode().apply {[weak self] label in
                        guard let self else { return }
                        label.text = "タップしてホームへ"
                        label.fontName = "AvenirNext-Medium"
                        label.fontSize = 30
                        label.fontColor = .white
                        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 30)
                        label.zPosition = 100
                    }.tracking(useInitialValue: false) {[weak self] in
                        self!.touchesEndedNodes
                    } onChange: {[weak self] label, nodes in
                        guard let self else { return }
                        guard nodes.contains(label) else { return }
                        let transition = SKTransition.crossFade(withDuration: 1.0)
                        self.view?.presentScene(
                            BlockBreakingGameHomeScene(size: size).apply { scene in
                                scene.scaleMode = .aspectFill

                            },
                            transition: SKTransition.crossFade(withDuration: 1.0)
                        )
                    }
                }
            case .playing:
                break
            case .gameOver:
                // ゲームオーバーシーンへ遷移
                let gameOverScene = BlockBreakingGameOverScene(size: size)
                gameOverScene.scaleMode = .aspectFill
                let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0) // ドアオープンアニメーション
                self.view?.presentScene(gameOverScene, transition: transition)
            }
        }
    }
}

private extension BlockBreakingGamePlayScene {
    func movePaddle(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 修正後: 式を分割する
        let halfPaddleWidth = paddle.frame.size.width / 2
        let minX = halfPaddleWidth
        let maxX = frame.width - halfPaddleWidth

        let desiredX = location.x
        let constrainedX = min(max(desiredX, minX), maxX) // minとmaxの順序を入れ替えることで、より直感的に範囲内に収めるロジックになる

        sceneModel.paddlePositionX = constrainedX
    }
}
