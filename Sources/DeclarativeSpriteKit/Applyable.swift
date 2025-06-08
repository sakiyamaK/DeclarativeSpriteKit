//
//  Applyable.swift
//  DeclarativeSpriteKit
//
//  Created by sakiyamaK on 2025/06/07.
//

import SpriteKit

// MARK: - Applyable
public protocol Applyable {}
extension Applyable {
    @discardableResult
    public func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension SKNode: Applyable {}
extension SKPhysicsBody: Applyable {}
