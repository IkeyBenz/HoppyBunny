import Foundation


class MainScene: CCNode, CCPhysicsCollisionDelegate {
    weak var hero: CCSprite!
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 200
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var obstaclesLayer: CCNode!
    weak var restartButton: CCButton!
    var gameOver = false
    var points: NSInteger = 0
    weak var scoreLabel: CCLabelTTF!
    
    var obstacles: [CCNode] = []
    let firstObstaclePosition: CGFloat = 280
    let distanceBetweenObstacles: CGFloat = 160
    
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    var grounds = [CCSprite] ()
    
    func didLoadFromCCB() {
        userInteractionEnabled = true       //Allowing touch to be recognized
        grounds.append(ground1)             //Adding grounds to the Groounds Array
        grounds.append(ground2)
        //Adding three initial Obstacles
        for i in (0...2) {
            println("spawned new at start")
            spawnNewObstacle()
        }
        gamePhysicsNode.collisionDelegate = self
        
        
    }
   
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
        hero.physicsBody.applyImpulse(ccp(0, 600)) //When the bunny is touched, it will jump 400 pixels. And spin upwards at 4000 somethings.
        hero.physicsBody.applyAngularImpulse(5000)
        sinceTouch = 0        //Reset sinceTouch variable to zero
        
        }
    }
   
    
    override func update(delta: CCTime) {
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        sinceTouch += delta
        hero.rotation = clampf(hero.rotation, -30, 40)
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 2)
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        if (sinceTouch > 0.3) {
            let impulse = -18000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        
        for ground in grounds {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }
       
        // ENDLESS OBSTACLES
        for obstacle in obstacles.reverse() {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
        }
    }
    
    func spawnNewObstacle() {
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstaclesLayer.addChild(obstacle)
        obstacle.setupRandomPosition()
        obstacles.append(obstacle)
    }
//  COLLISIONS
    // We pair two things that are going to collide by writing CCPhysicsCollisionPair!
    // We then state the name and type of both items that will collide. Our Hero will collide into the Level objects that were labeled in Sprite.
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        triggerGameOver()
        return true
    }
    func restart() {
        let scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(scene)
    }
    func triggerGameOver() {
        if (gameOver == false) {
            gameOver = true
            restartButton.visible = true
            scrollSpeed = 0
            hero.rotation = 90
            hero.physicsBody.allowsRotation = false
            hero.stopAllActions()
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let shakeSequence = CCActionSequence(array: [move, moveBack])
            runAction(shakeSequence)
        }
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero nodeA: CCNode!, goal: CCNode!) -> Bool {
        goal.removeFromParent()
        points++
        scoreLabel.string = String(points)
        return true
    }
}






