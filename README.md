# DeclarativeSpriteKit

[![Swift](https://img.shields.io/badge/Swift-5-orange?style=flat-square)](https://img.shields.io/badge/Swift-5-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS_-yellowgreen?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Twitter](https://img.shields.io/badge/twitter-@sakiyamaK-blue.svg?style=flat-square)](https://twitter.com/sakiyamaK)

SpriteKitを宣言的に記述するライブラリです

Library for writing SpriteKit declaratively.


```swift

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
```

* [Installation](#installation)
  * [Swift Package Manager](#swift-package-manager)

## Installation

### Swift Package Manager

Once you have your Swift package set up, adding DeclarativeUIKit as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com/sakiyamaK/DeclarativeUIKit", .upToNextMajor(from: "0.2"))
]
```

To install DeclarativeUIKit package via Xcode

Go to File -> Swift Packages -> Add Package Dependency...
Then search for https://github.com/sakiyamaK/DeclarativeUIKit
And choose the version you want