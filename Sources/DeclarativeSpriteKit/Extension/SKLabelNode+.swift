//
//  SKLabelNode+.swift
//  DeclarativeSpriteKit
//
//  Created by sakiyamaK on 2025/06/07.
//

import SpriteKit

public extension SKLabelNode {
    @discardableResult
    func text(_ text: String) -> Self {
        self.text = text
        return self
    }
    @discardableResult
    func fontSize(_ fontSize: CGFloat) -> Self {
        self.fontSize = fontSize
        return self
    }

    @discardableResult
    func fontColor(_ color: UIColor) -> Self {
        self.fontColor = color
        return self
    }

    @discardableResult
    func fontName(_ fontName: String) -> Self {
        self.fontName = fontName
        return self
    }
}
