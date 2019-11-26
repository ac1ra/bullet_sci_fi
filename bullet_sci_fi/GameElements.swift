//
//  GameElements.swift
//  bullet_sci_fi
//
//  Created by ac1ra on 21/11/2019.
//  Copyright © 2019 ac1ra. All rights reserved.
//

import SpriteKit

struct CollisionBitMask {
    static let bulletCategory:UInt32 = 0x1 >> 0
    static let pillarCategory: UInt32 = 0x1 >> 1
    static let flowerCategory: UInt32 = 0x1 >> 2
    static let groundCategory: UInt32 = 0x1 >> 3
}
extension GameScene{
    func createBullet() -> SKSpriteNode {
        //1 Here you create a sprite node called “bird” and assign it a texture named “bird1”. We give it a size of 50×50, however, you can adjust it to a different dimensions if you want to. Then, we position the bird in the center of the screen.
        
        let bullet = SKSpriteNode(texture: SKTextureAtlas(named: "player").textureNamed("bird1"))
        bullet.size = CGSize(width: 50, height: 50)
        bullet.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        //2 For the bird to be able to behave like a real world physics body (affected by gravity, collide with objects, etc.), it has to be a SKPhysicsBody object. We have defined it to behave like a ball of radius of half of its width.
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.linearDamping = 1.1
        bullet.physicsBody?.restitution = 0
        
        //3 A birdCategory is assigned to the player categoryBitMask property. If two bodies collide, we identify the two bodies by their categoryBitMasks. The collisionBitMask is set to pillarCategory and groundCategory to detect collisions with pillar and ground for this body. The contactTestBitMask is assigned to pillar, ground and flower because you will want to check for contacts with these bodies.
        
        bullet.physicsBody?.categoryBitMask = CollisionBitMask.bulletCategory
        bullet.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.groundCategory
        bullet.physicsBody?.collisionBitMask = CollisionBitMask.pillarCategory | CollisionBitMask.flowerCategory | CollisionBitMask.groundCategory
        
        //4 Here you set the bird to be affected by gravity. The bird will be pushed upward when you touch the screen and then will come down itself.
        
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        
        return bullet
    }
}
