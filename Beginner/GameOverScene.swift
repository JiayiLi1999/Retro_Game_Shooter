//
//  GameOverScene.swift
//  Beginner
//
//  Created by Jiayi Li on 2021/9/19.
//

import SpriteKit

class GameOverScene: SKScene {
  init(size: CGSize, won:Bool, score:NSInteger) {
    super.init(size: size)
    
    // 1
    backgroundColor = SKColor.white
    
    // 2
    let resultText = won ? "You Won!" : "You Lose :["
    let proceedText = "Press to continue"
    
    // 3
    
    let scoreText = SKLabelNode(fontNamed: "MarkerFelt-Wide")
    scoreText.fontColor = UIColor.black
    scoreText.fontSize = 20
    scoreText.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
    scoreText.zPosition = 100
    scoreText.text = "Your score is: "+String(score)
    self.addChild(scoreText)
    
    let result = SKLabelNode(fontNamed: "Charter-Bold")
    result.text = resultText
    result.fontSize = 40
    result.fontColor = SKColor.black
    result.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(result)
    
    let proceed = SKLabelNode(fontNamed: "Charter")
    proceed.text = proceedText
    proceed.fontSize = 20
    proceed.fontColor = SKColor.black
    proceed.position = CGPoint(x: self.frame.midX, y: size.height/5)
    addChild(proceed)
    
//    // 4
//    run(SKAction.sequence([
//      SKAction.wait(forDuration: 3.0),
//      SKAction.run() { [weak self] in
//        // 5
//        guard let `self` = self else { return }
//        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//        let scene = GameScene(size: size)
//        self.view?.presentScene(scene, transition:reveal)
//      }
//      ]))
   }
  
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startNewGame(){
        print("Start")
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene, transition:reveal)

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startNewGame()
    }
}
