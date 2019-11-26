

//
//  GameSce e].swift
//  bullet_sci_fi
//
//  Created by ac1ra on 21/11/2019.
//  Copyright © 2019 ac1ra. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
    let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKLabelNode()
    var pauseBtn = SKLabelNode()
    var logoImg = SKSpriteNode()
    var wallPair =  SKNode()
    var moveAndRemove = SKAction()
    
    //create the bird atlas for animation
    let bulletAtlas = SKTextureAtlas(named: "player")
    var bulletSprites = Array<Any>()
    var bullet = SKSpriteNode()
    var repeatActionBullet = SKAction()
    
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.bulletCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.bulletCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        //set up the bullet sprites for animation
        bulletSprites.append(bulletAtlas.textureNamed("bird1"))
        bulletSprites.append(bulletAtlas.textureNamed("bird2"))
        bulletSprites.append(bulletAtlas.textureNamed("bird3"))
        bulletSprites.append(bulletAtlas.textureNamed("bird4"))
        
        self.bullet = createBullet()
        self.addChild(bullet)
        
        //prepare to animate the bird and repeat the animation forever
        let animateBullet = SKAction.animate(with: self.bulletSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionBullet = SKAction.repeatForever(animateBullet)
        
    }
    
    override func didMove(to view: SKView) {
        createScene()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func update(_ currentTime: TimeInterval) {
        //called before each frame is rendered
        if isGameStarted == true {
            if isDied == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                    }
                }))
            }
        }
    }
}
