//
//  GameOverScene.swift
//  IOSZombieGame
//
//  Created by Das Tarlochan Preet Singh on 2020-06-12.
//  Copyright © 2020 Tarlochan5268. All rights reserved.
//
import Foundation
import SpriteKit
class GameOverScene: SKScene {
 let won:Bool
let score:Int
let scoresLabel = SKLabelNode(fontNamed: "Chalkduster")

init(size: CGSize, won: Bool, score: Int) {
 self.won = won
    self.score = score
 super.init(size: size)
 }

 required init(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
    
    override func didMove(to view: SKView) {
    var background: SKSpriteNode
    if (won) {
    background = SKSpriteNode(imageNamed: "bakground")
    run(SKAction.playSoundFileNamed("win.wav",
    waitForCompletion: false))
    } else {
        background = SKSpriteNode(imageNamed: "bakground")
        run(SKAction.playSoundFileNamed("lose.wav",
        waitForCompletion: false))
        }

        background.position =
        CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(background)

        // More here...
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run {
         let myScene = GameScene(size: self.size)
         myScene.scaleMode = self.scaleMode
         let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
         self.view?.presentScene(myScene, transition: reveal)
        }
        self.run(SKAction.sequence([wait, block]))
        if(won)
        {
            scoresLabel.text = "You Won the Game \n Coins Collected : \(score)"
        }
        else
        {
            scoresLabel.text = "You Lost the Game \n Coins Collected : \(score)"
        }
        
        scoresLabel.fontColor = SKColor.red
        scoresLabel.fontSize = 60
        scoresLabel.zPosition = 150
        scoresLabel.horizontalAlignmentMode = .center
        scoresLabel.verticalAlignmentMode = .center
        scoresLabel.position = CGPoint(x: 1000, y: 150)
        self.addChild(scoresLabel)
    }
    
    
}
