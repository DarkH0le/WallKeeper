//
//  GameScene.swift
//  WallKeeper
//
//  Created by Ivan Aldama on 23/04/18.
//  Copyright © 2018 Ivan Aldama. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    //Player Ref
    var player:SKSpriteNode?
    var playerTextureAtlas = SKTextureAtlas()
    var playerTextureArray = [SKTexture]()
    var playerAnimation:SKAction?
    
    // Trump Ref
    var trump:SKSpriteNode?
    var trumpTextureAtlas = SKTextureAtlas()
    var trumpTextureArray = [SKTexture]()
    var trumpAnimation:SKAction?
    
    //Action Ref
    var isTouched:Bool = false
    var touchLeft:Bool = false
    var touchRight:Bool = true
    var sidePress:Bool?  //Right: true Left:False
    
    //BitMask Categories
    //Porque usar el numero binario, io no c :v investigar depues
    let noCategory:UInt32 = 0
    let playerCategory:UInt32 = 0b1
    let trumpCategory:UInt32 = 0b1 << 1
    let spicyEnemyCategory:UInt32 = 0b1 << 2
    let pizzaEnemyCategory:UInt32 = 0b1 << 3
    let groundCategory:UInt32 = 0b1 << 4
    let gateCategory:UInt32 = 0b1 << 5
    let bulletCategory:UInt32 = 0b1 << 6
    
    //Gestures
    let swipeUpRec = UISwipeGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        //Setting Player
        setUpPlayer()
        
        //Trmmp Setting
        setUpTrump()
        
        //Setting Scene
        createGround()
        
        let bgSound:SKAudioNode = SKAudioNode(fileNamed: "bgSound.mp3")
        bgSound.autoplayLooped = true
        self.addChild(bgSound)
        
        //Setting collition delegate
        self.physicsWorld.contactDelegate = self
        
        //Setting Gestures
        //Swipe Up
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        //Tap
        tapRec.addTarget(self, action:#selector(GameScene.tappedView(_:) ))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
    }
    
    //Gestures Called Functions
    @objc func swipedUp() {
        
        player?.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 100))
    }
    
    @objc func tappedView(_ sender:UITapGestureRecognizer) {
        
        let point:CGPoint = sender.location(in: self.view)
        self.run(SKAction.playSoundFileNamed("shootSound", waitForCompletion: false))
        spawnBullet(Int(point.y))
    }
    //UserInteraction methods
    func touchDown(atPoint pos : CGPoint) {
        
        isTouched = true
        
        if pos.x > 0 {
            sidePress = touchRight
            
        } else {
            sidePress = touchLeft
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        isTouched = false
    }
    
    //Player Methods
    func moveRight(){
        player?.position.x += 50
    }
    
    func setUpTrump(){
        //Getting Trump´s node from the scene
        trump = self.childNode(withName: "Trump") as? SKSpriteNode
        
        //Setting bitmask and collitions
        //Physic body was set through the sks file
        trump?.physicsBody?.categoryBitMask = trumpCategory
        trump?.physicsBody?.collisionBitMask = noCategory
        trump?.physicsBody?.contactTestBitMask = playerCategory
        
        setTrumpAnimations()
    }
    
    func setTrumpAnimations() -> Void {
        
        trumpTextureAtlas = SKTextureAtlas(named: "Donald")
        
        print(trumpTextureAtlas.textureNames)
        
        for i in 0..<trumpTextureAtlas.textureNames.count - 1 {
            let textureName = "Trump_\(i).png"
            trumpTextureArray.append(SKTexture(imageNamed: textureName))
        }
        trumpAnimation = SKAction.repeatForever(SKAction.animate(with: trumpTextureArray, timePerFrame: 0.08))
        trump?.run(trumpAnimation!)
    }
    
    func setUpPlayer() -> Void {
        //Getting player from the sks
        player = self.childNode(withName: "Player") as? SKSpriteNode
        
        //Setting physics bitmask and collitions
        //Physic body was set through the sks file
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = spicyEnemyCategory | pizzaEnemyCategory | groundCategory
        player?.physicsBody?.contactTestBitMask = spicyEnemyCategory | pizzaEnemyCategory | trumpCategory | gateCategory
        
        //Setting animation
        setPlayerAnimation()
    }
    
    func setPlayerAnimation() {
        playerTextureAtlas = SKTextureAtlas(named: "Player")
        print(playerTextureAtlas.textureNames)
        
        for i in 0..<playerTextureAtlas.textureNames.count {
            let textureName = "Player_\(i).png"
            playerTextureArray.append(SKTexture(imageNamed: textureName))
        }
        playerAnimation = SKAction.repeatForever(SKAction.animate(with: playerTextureArray, timePerFrame: 0.3))
        player?.run(playerAnimation!)
    }
    
    func spawnBullet(_ hight:Int) {
        
        let scene:SKScene = SKScene(fileNamed: "Bullet")!
        let bullet = scene.childNode(withName: "Bullet")
        bullet?.position = CGPoint(x: 0, y: 0)
        bullet?.move(toParent: self)
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, remove])
        bullet?.run(sequence)
        bullet?.physicsBody?.categoryBitMask = bulletCategory
        bullet?.physicsBody?.collisionBitMask = noCategory
        bullet?.position = (player?.position)!
        bullet?.physicsBody?.applyImpulse(CGVector(dx: 3000, dy: Int(2300 - hight * 5)))
    }
    
    func spawnExplotion(_ givenPosition:CGPoint) -> Void {
        let explotion:SKEmitterNode = SKEmitterNode(fileNamed: "Explotion")!
        explotion.position = givenPosition
        self.addChild(explotion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //Scene Methods
    func createGround() {
        
        for i in 0...1 {

            let scene:SKScene = SKScene(fileNamed: "Ground")!
            let ground = scene.childNode(withName: "Ground") as! SKSpriteNode
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height / 2.5))
            ground.physicsBody?.categoryBitMask = groundCategory
            ground.physicsBody?.collisionBitMask = playerCategory | trumpCategory | spicyEnemyCategory | pizzaEnemyCategory
            ground.physicsBody?.contactTestBitMask = trumpCategory
            ground.move(toParent: self)
        }
    }
    
    func moveGround(_ isMoving:Bool) {
        
        if isMoving {
            self.enumerateChildNodes(withName: "Ground") { (node, error) in
                
                node.position.x -= 2
                
                if node.position.x < -((self.scene?.size.width)!){
                    node.position.x += (self.scene?.size.width)! * 2
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let cA:UInt32 = contact.bodyA.categoryBitMask
        let cB:UInt32 = contact.bodyB.categoryBitMask
        
        if cA == playerCategory || cB == playerCategory {
            let otherNode:SKNode = (cA == playerCategory) ? contact.bodyB.node! : contact.bodyA.node!
            playerDidCollide(with: otherNode)
        }
    }
    func playerDidCollide(with other:SKNode) {
        print("jugado colisiono")
        
        let otherCategory = other.physicsBody?.categoryBitMask
        
        if otherCategory == gateCategory {
            print("Bajar 50 vida gate, 20 trump, mas 30 puntos")
            player?.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 0))
        }
        if otherCategory == trumpCategory {
            print("Bajar Vida Trump")
            spawnExplotion(other.position)
            player?.physicsBody?.applyImpulse(CGVector(dx: -80, dy: 0))
            self.run(SKAction.playSoundFileNamed("soundWall2", waitForCompletion: false))
            
        } else if otherCategory == spicyEnemyCategory {
            print("Bajar 10 de vida jugador eliminar enemigo mas 5 puntos")
        } else if otherCategory == pizzaEnemyCategory {
            print("Bajar 15 vida jugador, eliminar enemigo, mas 10 puntos")
        }

    }
    
//    func playerDidCollide(with other:SKNode) {
//        let otherCategory = other.physicsBody?.categoryBitMask
//        print("antes del switch")
//
//        if otherCategory == trumpCategory {
//            other.removeFromParent()
//        }
////
////
////        if otherCategory == trumpCategory {
////            print("Bajar Vida Trump")
////            spawnExplotion(other.position)
////        } else if otherCategory == spicyEnemyCategory {
////            print("Bajar 10 de vida jugador eliminar enemigo mas 5 puntos")
////        } else if otherCategory == pizzaEnemyCategory {
////            print("Bajar 15 vida jugador, eliminar enemigo, mas 10 puntos")
////        } else if otherCategory == gateCategory {
////            print("Bajar 50 vida gate, 20 trump, mas 30 puntos")
////        }
//    }

    // Call After render each frame
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //Function to move the ground
        
        //MovePlayer
        if isTouched && (sidePress == touchRight) {
            moveGround(true)
            player?.position.x += 3
        } else {
            moveGround(true)
            player?.position.x -= 3
        }
        
        //Bounce the player to the righ of the screen
        if player!.position.x <= -(self.frame.size.width/2) {
            player?.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 10))
        }
        
    }
}
