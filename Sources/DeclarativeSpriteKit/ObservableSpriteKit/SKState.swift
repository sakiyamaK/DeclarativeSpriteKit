//
//  SKState.swift
//  DeclarativeSpriteKit
//
//  Created by sakiyamaK on 2025/06/07.
//

import Foundation

@available(iOS 17.0, *)
@propertyWrapper
@Observable
@MainActor
public final class SKState<Value> {
    public private(set) var value: Value
    public var wrappedValue: Value {
        get {
            value
        }
        set {
            value = newValue
        }
    }

    public init (wrappedValue: Value) {
        self.value = wrappedValue
    }
}
