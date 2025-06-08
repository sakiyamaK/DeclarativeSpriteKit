//
//  BlockBreakingPhysicsCategory.swift
//  DeclarativeSpriteKitDemo
//
//  Created by sakiyamaK on 2025/06/08.
//

import Foundation

struct BlockBreakingPhysicsCategory {
    static let None: UInt32 = 0
    static let Ball: UInt32 = 0b1
    static let Paddle: UInt32 = 0b10
    static let Block: UInt32 = 0b100
    static let Wall: UInt32 = 0b1000
    static let Bottom: UInt32 = 0b10000
}
