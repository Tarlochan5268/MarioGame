//
//  GameScene.swift
//
//  Created by Das Tarlochan Preet Singh on 2020-06-10.
//  Copyright © 2020 Tarlochan5268. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene2: SKScene {
    
    let hero = SKSpriteNode(imageNamed: "mario1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    let marioAnimation: SKAction

    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0

    
    var invincible = false
    var lives = 5
    var gameOver = false
    
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
       "loselifeSound.wav", waitForCompletion: false)
  
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                          width: size.width,
                          height: playableHeight)
    
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...12 {
          textures.append(SKTexture(imageNamed: "mario\(i)"))
        }
        // 3
        textures.append(textures[11])
        textures.append(textures[10])
        textures.append(textures[9])
        textures.append(textures[8])
        textures.append(textures[7])
        textures.append(textures[6])
        textures.append(textures[5])
        textures.append(textures[4])
        textures.append(textures[3])
        textures.append(textures[2])

        // 4
        marioAnimation = SKAction.animate(with: textures,
          timePerFrame: 0.1)
      
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
//        playBackgroundMusic(filename: "BgSound.wav")
        createBackground()
        hero.position = CGPoint(x: 550, y: 465)
        hero.zPosition = 100
        addChild(hero)
        hero.run(SKAction.repeatForever(marioAnimation))
        
        run(SKAction.repeatForever(
          SKAction.sequence([SKAction.run() { [weak self] in
                          self?.spawnEnemy()
                        },
                        SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(
        SKAction.sequence([SKAction.run() { [weak self] in
                            self?.spawnCoin()
                          },
                          SKAction.wait(forDuration: 1.0)])))
        
        livesLabel.text = "Lives: X"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(
            x: playableRect.size.width - CGFloat(320),
            y: playableRect.size.height - CGFloat(20))
        addChild(livesLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    func touchDown(atPoint pos: CGPoint) {
        print("jump")
        jump()
    }

    func jump() {
        playBackgroundMusic(filename: "jumpSound.wav")
        let jumpUpAction = SKAction.moveBy(x: 0, y: 300, duration: 0.3)
        // move down 20
        let jumpDownAction = SKAction.moveBy(x: 0, y: -300, duration: 0.6)
        // sequence of move yup then down
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])

        // make player run sequence
        hero.run(jumpSequence)
//        hero.texture = SKTexture(imageNamed: "mario1")
//        hero.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 500))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    func touchUp(atPoint pos: CGPoint) {
        hero.texture = SKTexture(imageNamed: "mario1")
        backgroundMusicPlayer.stop()
        playBackgroundMusic(filename: "BgSound.wav")
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
   
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        self.lastUpdateTime = currentTime
        
        moveCamera()
    
    }
    
    override func didEvaluateActions() {
       checkCollisions()
     }
    
    
    func debugDrawPlayableArea() {
       let shape = SKShapeNode()
       let path = CGMutablePath()
       path.addRect(playableRect)
       shape.path = path
       shape.strokeColor = SKColor.red
       shape.lineWidth = 4.0
       addChild(shape)
     }
    
    func createBackground() {
                 let backgroundTexture = SKTexture(imageNamed: "bakground")

                 for i in 0 ... 1{
                     let background = SKSpriteNode(texture: backgroundTexture)
                     background.zPosition = -1
                     background.anchorPoint = CGPoint(x: 0, y: 0.5)
                     background.position = CGPoint(x:  (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: size.height/2)
                   let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 10)
                   let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
                   let moveLoop = SKAction.sequence([moveLeft, moveReset])
                   let moveForever = SKAction.repeatForever(moveLoop)
                   background.run(moveForever)
                   addChild(background)
                 }
       }
    func spawnCoin() {
      // 1
      let coin = SKSpriteNode(imageNamed: "coin")
      coin.name = "coin"
      coin.position = CGPoint(
        x: CGFloat.random(min: cameraRect.minX,
                          max: cameraRect.maxX),
        y: CGFloat.random(min: cameraRect.minY,
                          max: cameraRect.maxY))
      coin.zPosition = 50
      coin.setScale(0)
      addChild(coin)
      // 2
      let appear = SKAction.scale(to: 1.0, duration: 0.5)

      coin.zRotation = -π / 16.0
      let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
      let rightWiggle = leftWiggle.reversed()
      let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
      
      let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
      let scaleDown = scaleUp.reversed()
      let fullScale = SKAction.sequence(
        [scaleUp, scaleDown, scaleUp, scaleDown])
      let group = SKAction.group([fullScale, fullWiggle])
      let groupWait = SKAction.repeat(group, count: 10)
      
      let disappear = SKAction.scale(to: 0, duration: 0.5)
      let removeFromParent = SKAction.removeFromParent()
      let actions = [appear, groupWait, disappear, removeFromParent]
      coin.run(SKAction.sequence(actions))
    }
    
    func spawnEnemy() {
      let enemy = SKSpriteNode(imageNamed: "Enemy")
      enemy.position = CGPoint(
        x: self.playableRect.width + enemy.size.width/2,
        y: 460)
      enemy.zPosition = 50
      enemy.name = "Enemy"
      addChild(enemy)
      
      let actionMove =
        SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 2.0)
      let actionRemove = SKAction.removeFromParent()
      enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func checkCollisions() {
      
       
       if invincible {
         return
       }
      
       var hitEnemies: [SKSpriteNode] = []
       enumerateChildNodes(withName: "enemy") { node, _ in
         let enemy = node as! SKSpriteNode
         if node.frame.insetBy(dx: 20, dy: 20).intersects(
           self.hero.frame) {
           hitEnemies.append(enemy)
         }
       }
       for enemy in hitEnemies {
         zombieHit(enemy: enemy)
       }
     }
    
    func zombieHit(enemy: SKSpriteNode) {
      invincible = true
      let blinkTimes = 10.0
      let duration = 3.0
      let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
        let slice = duration / blinkTimes
        let remainder = Double(elapsedTime).truncatingRemainder(
          dividingBy: slice)
        node.isHidden = remainder > slice / 2
      }
      let setHidden = SKAction.run() { [weak self] in
        self?.hero.isHidden = false
        self?.invincible = false
      }
      hero.run(SKAction.sequence([blinkAction, setHidden]))
      
      run(enemyCollisionSound)
      lives -= 1
    }
    
    
    func backgroundNode() -> SKSpriteNode {
      // 1
      let backgroundNode = SKSpriteNode()
      backgroundNode.anchorPoint = CGPoint.zero
      backgroundNode.name = "bakground"

      // 2
      let background1 = SKSpriteNode(imageNamed: "bakground")
      background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0.5, y: 0.5)
      backgroundNode.addChild(background1)

      // 3
      let background2 = SKSpriteNode(imageNamed: "bakground")
      background2.anchorPoint = CGPoint.zero
      background2.position =
        CGPoint(x: background1.size.width, y: 0.5)
      backgroundNode.addChild(background2)

      // 4
      backgroundNode.size = CGSize(
        width: background1.size.width + background2.size.width,
        height: background1.size.height)
      return backgroundNode
    }
    
    func moveCamera() {
      let backgroundVelocity =
        CGPoint(x: cameraMovePointsPerSec, y: 0)
      let amountToMove = backgroundVelocity * CGFloat(dt)
      cameraNode.position += amountToMove

      enumerateChildNodes(withName: "background") { node, _ in
        let background = node as! SKSpriteNode
        if background.position.x + background.size.width <
            self.cameraRect.origin.x {
          background.position = CGPoint(
            x: background.position.x + background.size.width*2,
            y: background.position.y)
        }
      }
    }
//
    var cameraRect : CGRect {
       let x = cameraNode.position.x - size.width/2
           + (size.width - playableRect.width)/2
       let y = cameraNode.position.y - size.height/2
           + (size.height - playableRect.height)/2
       return CGRect(
         x: x,
         y: y,
         width: playableRect.width,
         height: playableRect.height)
     }
}
