//
//  SKScene+.swift
//  DeclarativeSpriteKit
//
//  Created by sakiyamaK on 2025/06/07.
//

import SpriteKit

public extension SKScene {
    @discardableResult
    func addChildren(@ArrayNodeBuilder _ builder: () -> [SKNode]) -> Self {
        let contents = builder()
        for content in contents {
            self.addChild(content)
        }
        return self
    }

    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
}
