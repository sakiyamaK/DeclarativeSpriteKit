//
//  SKNote+.swift
//  DeclarativeSpriteKit
//
//  Created by sakiyamaK on 2025/06/07.
//

import SpriteKit

public extension SKNode {
    @discardableResult
    func position(_ position: CGPoint) -> Self {
        self.position = position
        return self
    }

    @discardableResult
    func zPosition(_ zPosition: CGFloat) -> Self {
        self.zPosition = zPosition
        return self
    }

    @discardableResult
    func run(_ actionHandler: @escaping () -> SKAction) -> Self {
        self.run(actionHandler())
        return self
    }
}
