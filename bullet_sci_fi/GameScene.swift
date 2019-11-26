

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
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
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
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    override func didMove(to view: SKView) {
        createScene()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isGameStarted == false{
            //1
            isGameStarted = true
            bullet.physicsBody?.affectedByGravity = true
            createPauseBtn()
            //2
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3),completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            //3
            self.bullet.run(repeatActionBullet)
            
            //TODO add pillars here
            //1 This run an action that creates and add pillar pairs to the scene.
            
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })
            
            //2 Here you wait for 1.5 seconds for the next set of pillars to be generated. A sequence of actions will run the spawn and delay actions forever.
            
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            //3 This will move and remove the pillars. You set the distance that the pillars have to move which is the sum of the screen and the pillar width. Another sequence of action will run in order to move and remove the pillars. Pillars start moving to the left of the screen as they are created and are deallocated when they go off the screen.
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePillars = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePillars, removePillars])
            
            bullet.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bullet.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            
        } else {
            if isDied == false{
                bullet.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bullet.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        for touch in touches{
            let location = touch.location(in: self)
            //1
            if isDied == true{
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
            } else {
                //2
                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
        
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
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.bulletCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.bulletCategory || firstBody.categoryBitMask == CollisionBitMask.bulletCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.bulletCategory {
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if isDied == false{
                isDied = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.bullet.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.bulletCategory && secondBody.categoryBitMask == CollisionBitMask.flowerCategory{
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.flowerCategory && secondBody.categoryBitMask == CollisionBitMask.bulletCategory{
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
        
    }
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }
}
