//
//  GameScene.swift
//  Beginner
//
//  Created by Jiayi Li on 2021/9/19.
//

import SpriteKit


// operator overloading
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
}


extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


class GameScene: SKScene, SKPhysicsContactDelegate{
    let player = SKSpriteNode(imageNamed: "girl")
    var monstersDestroyed = 0
    var scoreLabelNode:SKLabelNode!
    var targetLabelNode:SKLabelNode!
    var score = 0
    var target = 10

      
    override func didMove(to view: SKView) {
        
        // background setting
        backgroundColor = SKColor.white
        let backgroundMusic = SKAudioNode(fileNamed: "BGM.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        // basic data setting
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
        targetLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        targetLabelNode.fontColor = UIColor.black
        targetLabelNode.fontSize = 13
        targetLabelNode.position = CGPoint( x: self.frame.midX, y: 5 * self.frame.size.height / 6 )
        targetLabelNode.zPosition = 100
        targetLabelNode.text = "Your target is: "+String(target)
        self.addChild(targetLabelNode)
        
        
        // physics setting
        physicsWorld.gravity = CGVector( dx: 0.0, dy: 0.0 )
        physicsWorld.contactDelegate = self
        
        // avater setting
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        // monster generating
        run(SKAction.repeatForever(
              SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
                ])
            ))
        
    }
    
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }

    func addMonster() {
      
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "duck.PNG")
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        // Add the monster to the scene
        addChild(monster)

        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
      
        
        let loseAction = SKAction.run() { [weak self] in
          guard let `self` = self else { return }
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false, score:self.score)
          self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5

    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
        return
        }
        //run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        let touchLocation = touch.location(in: self)

        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "dog.PNG")
        projectile.position = player.position

        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position

        // 4 - Bail out if you are shooting down or backwards
        if offset.x < 0 { return }

        // 5 - OK to add now - you've double checked position
        addChild(projectile)

        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()

        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000

        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position

        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 3)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
    }
    
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        self.addScore()
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed += 1
        if monstersDestroyed >= target {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true, score:self.score)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func addScore(){
        score += 1
        scoreLabelNode.text = String(score)
        scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
    }

    func didBegin(_ contact: SKPhysicsContact) {
      // 1
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
     
      // 2
      if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
        if let monster = firstBody.node as? SKSpriteNode,
          let projectile = secondBody.node as? SKSpriteNode {
          projectileDidCollideWithMonster(projectile: projectile, monster: monster)
        }
      }
    }


   
}

