//
//  GameScene.swift
//  IOSmarioGame
//
//  Created by Das Tarlochan Preet Singh on 2020-06-10.
//  Copyright © 2020 Tarlochan5268. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  let mario = SKSpriteNode(imageNamed: "mario1")
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    let scoresLabel = SKLabelNode(fontNamed: "Chalkduster")
  let marioMovePointsPerSec: CGFloat = 480.0
  var velocity = CGPoint.zero
  let playableRect: CGRect
 var coinCollected = 0
  var lastTouchLocation: CGPoint?
  let marioRotateRadiansPerSec:CGFloat = 4.0 * π
  let marioAnimation: SKAction
    let marioMove: SKAction
  let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "Mario-coin-sound.mp3", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCatLady.wav", waitForCompletion: false)
  var invincible = false
  let catMovePointsPerSec:CGFloat = 480.0
  var lives = 5
  var gameOver = false
  let cameraNode = SKCameraNode()
  let cameraMovePointsPerSec: CGFloat = 200.0

  
  
 
  
  
  
  override func update(_ currentTime: TimeInterval) {
  
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
  
    /*
    if let lastTouchLocation = lastTouchLocation {
      let diff = lastTouchLocation - mario.position
      if diff.length() <= marioMovePointsPerSec * CGFloat(dt) {
        mario.position = lastTouchLocation
        velocity = CGPoint.zero
        stopmarioAnimation()
      } else {
      */
        move(sprite: mario, velocity: velocity)
      /*}
    }*/
  
    boundsCheckmario()
    // checkCollisions()
    moveTrain()

livesLabel.text = "Lives: \(lives)"
    scoresLabel.text = "Coins: \(coinCollected)"
    moveCamera()
    
    if lives <= 0 && !gameOver {
      gameOver = true
      print("You lose!")
      backgroundMusicPlayer.stop()
      
      // 1
        let gameOverScene = GameOverScene(size: size, won: false , score: coinCollected)
      gameOverScene.scaleMode = scaleMode
      // 2
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      // 3
      view?.presentScene(gameOverScene, transition: reveal)
    }
    
    // cameraNode.position = mario.position
    
  }
  
  
    func touchDown(atPoint pos: CGPoint) {
        print("jump")
        jump()
    }
  func jump() {
          playBackgroundMusic(filename: "jumpSound.wav")
          let jumpUpAction = SKAction.moveBy(x: 0, y: 330, duration: 0.33)
          // move down 20
          let jumpDownAction = SKAction.moveBy(x: 0, y: -330, duration: 0.63)
          // sequence of move yup then down
          let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])

          // make player run sequence
          mario.run(jumpSequence)
  //        hero.texture = SKTexture(imageNamed: "mario1")
  //        hero.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 500))
      }
  
  func moveTrain() {
  
    var trainCount = 0
    var targetPosition = mario.position
    
    enumerateChildNodes(withName: "train") { node, stop in
      trainCount += 1
      if !node.hasActions() {
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.catMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
        node.run(moveAction)
      }
      targetPosition = node.position
    }
    
    if trainCount >= 15 && !gameOver {
      gameOver = true
      print("You win!")
      backgroundMusicPlayer.stop()
      
      // 1
        let gameOverScene = GameOverScene(size: size, won: true, score: coinCollected)
      gameOverScene.scaleMode = scaleMode
      // 2
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      // 3
      view?.presentScene(gameOverScene, transition: reveal)
    }
    
  }
  
  func loseCats() {
    // 1
    var loseCount = 0
    enumerateChildNodes(withName: "train") { node, stop in
      // 2
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.y += CGFloat.random(min: -100, max: 100)
      // 3
      node.name = ""
      node.run(
        SKAction.sequence([
          SKAction.group([
            SKAction.rotate(byAngle: π*4, duration: 1.0),
            SKAction.move(to: randomSpot, duration: 1.0),
            SKAction.scale(to: 0, duration: 1.0)
            ]),
          SKAction.removeFromParent()
        ]))
      // 4
      loseCount += 1
      if loseCount >= 2 {
        stop[0] = true
      }
    }
  }
  
  
    //no Change
    
    func spawnEnemy() {
      let enemy = SKSpriteNode(imageNamed: "Enemy")
      enemy.position = CGPoint(
        x: cameraRect.maxX + enemy.size.width/2,
        y: cameraRect.minY + 100)
      enemy.zPosition = 50
      enemy.name = "enemy"
      addChild(enemy)
      
      let actionMove =
        SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 3.0)
      let actionRemove = SKAction.removeFromParent()
      enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat() {
      // 1
      let cat = SKSpriteNode(imageNamed: "coin")
      cat.name = "cat"
      cat.position = CGPoint(
        x: CGFloat.random(min: cameraRect.minX,
                          max: cameraRect.maxX),
        y: CGFloat.random(min: cameraRect.minY,
                          max: cameraRect.maxY))
      cat.zPosition = 50
      cat.setScale(0)
      addChild(cat)
      // 2
      let appear = SKAction.scale(to: 1.0, duration: 0.5)

      cat.zRotation = -π / 16.0
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
        let actionMove = SKAction.moveBy(x: -(size.width + cat.size.width), y: 0, duration: 3.0)
      let actions = [appear, actionMove, removeFromParent]
      cat.run(SKAction.sequence(actions))
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
      let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                 y: velocity.y * CGFloat(dt))
      sprite.position += amountToMove
    }
    
    func movemarioToward(location: CGPoint) {
      startmarioAnimation()
      let offset = location - mario.position
      let direction = offset.normalized()
      velocity = direction * marioMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
      lastTouchLocation = touchLocation
      movemarioToward(location: touchLocation)
    }

    override func touchesBegan(_ touches: Set<UITouch>,
        with event: UIEvent?) {
      //guard let touch = touches.first else {
      //  return
      //}
      ///let touchLocation = touch.location(in: self)
      //sceneTouched(touchLocation: touchLocation)
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>,
        with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.location(in: self)
      sceneTouched(touchLocation: touchLocation)
    }
    
    func boundsCheckmario() {
      let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
      let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
      
      if mario.position.x <= bottomLeft.x {
        mario.position.x = bottomLeft.x
        velocity.x = abs(velocity.x)
      }
      if mario.position.x >= topRight.x {
        mario.position.x = topRight.x
        velocity.x = -velocity.x
      }
      if mario.position.y <= bottomLeft.y {
        mario.position.y = bottomLeft.y
        velocity.y = -velocity.y
      }
      if mario.position.y >= topRight.y {
        mario.position.y = topRight.y
        velocity.y = -velocity.y
      }
    }
    override func didMove(to view: SKView) {

      playBackgroundMusic(filename: "BgSound.wav")
    
      for i in 0...1 {
        let background = backgroundNode()
        background.anchorPoint = CGPoint.zero
        background.position =
          CGPoint(x: CGFloat(i)*background.size.width, y: 0)
        background.name = "bakground"
        background.zPosition = -1
        addChild(background)
      }
      
      mario.position = CGPoint(x: 600, y: 350)
      mario.zPosition = 100
      addChild(mario)
        mario.run(SKAction.repeatForever(marioAnimation))
        
        mario.run(SKAction.repeatForever(marioMove))
      // mario.run(SKAction.repeatForever(marioAnimation))
      
      run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in
                        self?.spawnEnemy()
                      },SKAction.wait(forDuration: 2.0)])))

      run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in
                            self?.spawnCat()
                          },SKAction.wait(forDuration: 1.0)])))
      
      // debugDrawPlayableArea()
      
      addChild(cameraNode)
      camera = cameraNode
      cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
      
            livesLabel.text = "Lives: X"
            livesLabel.fontColor = SKColor.red
            livesLabel.fontSize = 100
            livesLabel.zPosition = 150
            livesLabel.horizontalAlignmentMode = .left
            livesLabel.verticalAlignmentMode = .bottom
            livesLabel.position = CGPoint(
                x: -playableRect.size.width/2 + CGFloat(20),
                y: -playableRect.size.height/2 + CGFloat(1100))
            cameraNode.addChild(livesLabel)
        
        scoresLabel.text = "Coins : \(coinCollected)"
        scoresLabel.fontColor = SKColor.red
        scoresLabel.fontSize = 100
        scoresLabel.zPosition = 150
        scoresLabel.horizontalAlignmentMode = .left
        scoresLabel.verticalAlignmentMode = .bottom
        scoresLabel.position = CGPoint(
            x: playableRect.size.width/2 - CGFloat(500),
            y: -playableRect.size.height/2 + CGFloat(1100))
        cameraNode.addChild(scoresLabel)
    }
    
   
    
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
      textures.append(textures[2])
      textures.append(textures[1])

      // 4
      marioAnimation = SKAction.animate(with: textures,
        timePerFrame: 0.1)
        marioMove = SKAction.moveBy(x: 0 + mario.size.width, y: 0, duration: 1.5)
      super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func marioHit(cat: SKSpriteNode) {
      cat.name = "train"
      cat.removeAllActions()
      cat.setScale(1.0)
      cat.zRotation = 0
      
      let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
      cat.run(turnGreen)
        cat.isHidden = true
      coinCollected+=1
      run(catCollisionSound)
    }
    func marioHit(enemy: SKSpriteNode) {
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
        self?.mario.isHidden = false
        self?.invincible = false
      }
      mario.run(SKAction.sequence([blinkAction, setHidden]))
      
      run(enemyCollisionSound)
      
      loseCats()
      lives -= 1
    }
    
    func checkCollisions() {
      var hitCats: [SKSpriteNode] = []
      enumerateChildNodes(withName: "cat") { node, _ in
        let cat = node as! SKSpriteNode
        if cat.frame.intersects(self.mario.frame) {
          hitCats.append(cat)
        }
      }
      
      for cat in hitCats {
        marioHit(cat: cat)
      }
      
      if invincible {
        return
      }
     
      var hitEnemies: [SKSpriteNode] = []
      enumerateChildNodes(withName: "enemy") { node, _ in
        let enemy = node as! SKSpriteNode
        if node.frame.insetBy(dx: 60, dy: 60).intersects(
          self.mario.frame) {
          hitEnemies.append(enemy)
        }
      }
      for enemy in hitEnemies {
        marioHit(enemy: enemy)
      }
    }
    
    override func didEvaluateActions() {
      checkCollisions()
    }
    
    func startmarioAnimation() {
      if mario.action(forKey: "animation") == nil {
        mario.run(
          SKAction.repeatForever(marioAnimation),
          withKey: "animation")
      }
    }

    func stopmarioAnimation() {
      mario.removeAction(forKey: "animation")
    }


    func backgroundNode() -> SKSpriteNode {
      // 1
      let backgroundNode = SKSpriteNode()
      backgroundNode.anchorPoint = CGPoint.zero
      backgroundNode.name = "bakground"

      // 2
      let background1 = SKSpriteNode(imageNamed: "bakground")
      background1.anchorPoint = CGPoint.zero
      background1.position = CGPoint(x: 0, y: 0)
      backgroundNode.addChild(background1)
      
      // 3
      let background2 = SKSpriteNode(imageNamed: "bakground")
      background2.anchorPoint = CGPoint.zero
      background2.position =
        CGPoint(x: background1.size.width, y: 0)
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
      
      enumerateChildNodes(withName: "bakground") { node, _ in
        let background = node as! SKSpriteNode
        if background.position.x + background.size.width <
            self.cameraRect.origin.x {
          background.position = CGPoint(
            x: background.position.x + background.size.width*2,
            y: background.position.y)
        }
      }
      
    }
    
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
    
    
    func debugDrawPlayableArea() {
          let shape = SKShapeNode()
          let path = CGMutablePath()
          path.addRect(playableRect)
          shape.path = path
          shape.strokeColor = SKColor.red
          shape.lineWidth = 4.0
          addChild(shape)
        }
    
    
}
