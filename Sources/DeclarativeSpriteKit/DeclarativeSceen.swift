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

    // MARK: - 各タッチイベントに対応するクロージャを保持するプロパティ
    private var touchesBeganHandler: ((Set<UITouch>, UIEvent?) -> Void)?
    private var touchesMovedHandler: ((Set<UITouch>, UIEvent?) -> Void)?
    private var touchesEndedHandler: ((Set<UITouch>, UIEvent?) -> Void)?
    private var touchesCancelledHandler: ((Set<UITouch>, UIEvent?) -> Void)?

    @SKState public private(set) var touchesBeganNodes: [SKNode] = []
    @SKState public private(set) var touchesMovedNodes: [SKNode] = []
    @SKState public private(set) var touchesEndedNodes: [SKNode] = []
    @SKState public private(set) var touchesCancelledNodes: [SKNode] = []

    private var defaultTouchesNodesProvider: ((SKScene, Set<UITouch>) -> [SKNode]) = { scene, touches in
        if let touch = touches.first {
            scene.nodes(at: touch.location(in: scene))
        } else {
            []
        }
    }

    lazy var touchesBeganNodesProvider: ((SKScene, Set<UITouch>) -> [SKNode]) = defaultTouchesNodesProvider
    lazy var touchesMovedNodesProvider: ((SKScene, Set<UITouch>) -> [SKNode]) = defaultTouchesNodesProvider
    lazy var touchesEndedNodesProvider: ((SKScene, Set<UITouch>) -> [SKNode]) = defaultTouchesNodesProvider
    lazy var touchesCancelledNodesProvider: ((SKScene, Set<UITouch>) -> [SKNode]) = defaultTouchesNodesProvider


    // MARK: - Physics Contact Handlers
       // 衝突イベントに対応するクロージャを保持するプロパティ
    private var didBeginContactHandler: ((SKPhysicsContact) -> Void)?
    private var didEndContactHandler: ((SKPhysicsContact) -> Void)?

    // MARK: - Override Touch Methods

    open override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        didMoveHandler?(self, view)
    }
    // 本来のタッチイベントメソッドをオーバーライドし、保持しているクロージャを実行する

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchesBeganNodes = touchesBeganNodesProvider(self, touches)
        touchesBeganHandler?(touches, event)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchesMovedNodes = touchesMovedNodesProvider(self, touches)
        touchesMovedHandler?(touches, event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEndedNodes = touchesEndedNodesProvider(self, touches)
        touchesEndedHandler?(touches, event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesCancelledNodes = touchesCancelledNodesProvider(self, touches)
        touchesCancelledHandler?(touches, event)
    }
}

// MARK: - Event Handlers Registration
// これらのメソッドを使って、外部から処理をインジェクト（注入）する
public extension DeclarativeScene {

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
// MARK: - Physics Contact Handlers Registration
// 衝突イベントハンドラの登録メソッドを追加
public extension DeclarativeScene {
    @discardableResult
    func didBeginContact(_ handler: @escaping (SKPhysicsContact) -> Void) -> Self {
        self.didBeginContactHandler = handler
        return self
    }

    @discardableResult
    func didEndContact(_ handler: @escaping (SKPhysicsContact) -> Void) -> Self {
        self.didEndContactHandler = handler
        return self
    }
}

extension DeclarativeScene: @preconcurrency SKPhysicsContactDelegate {
    public func didBegin(_ contact: SKPhysicsContact) {
        Task { @MainActor in
            didBeginContactHandler?(contact)
        }
    }

    public func didEnd(_ contact: SKPhysicsContact) {
        Task { @MainActor in
            didEndContactHandler?(contact)
        }
    }
}
