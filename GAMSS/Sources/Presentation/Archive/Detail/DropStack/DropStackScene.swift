//
//  DropStackScene.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import SpriteKit

final class DropStackScene: SKScene {
    private let floorNodeName = "drop-floor"
    private let boxNodeName = "drop-note"
    private let dropSize = CGSize(width: 80, height: 80)
    private let floorHeight: CGFloat = 12

    private var pendingNotes: [DropNote] = []
    private var isAttachedToView = false

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        view.isPaused = false
        isPaused = false
        isAttachedToView = true
        configurePhysics()
        flushPendingNotesIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        configurePhysics()
    }

    func updateSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        size = newSize
        configurePhysics()
    }

    func render(notes: [DropNote]) {
        pendingNotes = notes
        flushPendingNotesIfNeeded()
    }

    func clear() {
        removeAllActions()
        pendingNotes = []
        children
            .filter { $0.name == boxNodeName }
            .forEach { $0.removeFromParent() }
    }

    private func flushPendingNotesIfNeeded() {
        guard isAttachedToView, size.width > 0, size.height > 0, !pendingNotes.isEmpty else {
            return
        }

        let notes = pendingNotes
        pendingNotes = []

        removeAllActions()
        children
            .filter { $0.name == boxNodeName }
            .forEach { $0.removeFromParent() }

        for (index, note) in notes.enumerated() {
            let wait = SKAction.wait(forDuration: 0.07 * Double(index))
            let spawn = SKAction.run { [weak self] in
                self?.spawnOne(imageName: note.imageName)
            }
            run(.sequence([wait, spawn]))
        }
    }

    private func configurePhysics() {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.5)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        childNode(withName: floorNodeName)?.removeFromParent()
        addFloor()
    }

    private func addFloor() {
        let floor = SKNode()
        floor.name = floorNodeName
        floor.position = CGPoint(x: frame.midX, y: floorHeight * 0.5)
        floor.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: frame.width, height: floorHeight)
        )
        floor.physicsBody?.isDynamic = false
        addChild(floor)
    }

    private func spawnOne(imageName: String) {
        let node = SKSpriteNode(imageNamed: imageName)
        node.name = boxNodeName
        node.size = dropSize

        let minX = dropSize.width * 0.5
        let maxX = max(minX, frame.width - dropSize.width * 0.5)
        let x = CGFloat.random(in: minX...maxX)
        // 화면 상단 안쪽에서 시작해야 물리 시뮬레이션이 바로 적용된다.
        node.position = CGPoint(x: x, y: frame.height - dropSize.height * 0.5)

        let body = SKPhysicsBody(rectangleOf: dropSize)
        body.isDynamic = true
        body.affectedByGravity = true
        body.restitution = 0.05
        body.friction = 0.85
        body.linearDamping = 0.3
        body.angularDamping = 0.8
        node.physicsBody = body

        addChild(node)
    }
}
