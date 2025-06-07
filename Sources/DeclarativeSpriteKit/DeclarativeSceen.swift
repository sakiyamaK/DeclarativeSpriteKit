//
//  DeclarativeSceen.swift
//  DeclarativeSpriteKit
//
//  Created by sakiyamaK on 2025/06/07.
//

import SpriteKit

/// 宣言的な記述をサポートするためのベースとなるSKScene
open class DeclarativeScene: SKScene {

    private var didMoveHandler: ((DeclarativeScene, SKView) -> Void)?
    // 各タッチイベントに対応するクロージャを保持するプロパティ
    private var touchesBeganHandler: ((Set<UITouch>, UIEvent?) -> Void)?
    private var touchesMovedHandler: ((Set<UITouch>, UIEvent?) -> Void)?
    private var touchesEndedHandler: ((Set<UITouch>, UIEvent?) -> Void)?
    private var touchesCancelledHandler: ((Set<UITouch>, UIEvent?) -> Void)?

    // MARK: - Override Touch Methods

    open override func didMove(to view: SKView) {
        super.didMove(to: view)
        didMoveHandler?(self, view)
    }
    // 本来のタッチイベントメソッドをオーバーライドし、保持しているクロージャを実行する

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesBeganHandler?(touches, event)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchesMovedHandler?(touches, event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEndedHandler?(touches, event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesCancelledHandler?(touches, event)
    }
}

public extension DeclarativeScene {
    // MARK: - Event Handlers Registration
    // これらのメソッドを使って、外部から処理をインジェクト（注入）する

    @discardableResult
    func didMove(_ handler: @escaping ((DeclarativeScene, SKView) -> Void)) -> Self {
        self.didMoveHandler = handler
        return self
    }

    @discardableResult
    func touchesBegan(_ handler: @escaping (Set<UITouch>, UIEvent?) -> Void) -> Self {
        self.touchesBeganHandler = handler
        return self
    }

    @discardableResult
    func touchesMoved(_ handler: @escaping (Set<UITouch>, UIEvent?) -> Void) -> Self {
        self.touchesMovedHandler = handler
        return self
    }

    @discardableResult
    func touchesEnded(_ handler: @escaping (Set<UITouch>, UIEvent?) -> Void) -> Self {
        self.touchesEndedHandler = handler
        return self
    }

    @discardableResult
    func touchesCancelled(_ handler: @escaping (Set<UITouch>, UIEvent?) -> Void) -> Self {
        self.touchesCancelledHandler = handler
        return self
    }
}
