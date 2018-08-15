//
//  GameScene.swift
//  SpaceRun
//
//  Created by Bee Yang on 11/22/17.
//  Copyright © 2017 assignment2 Bee Yang. All rights reserved.
//

import SpriteKit
// import GameplayKit

class GameScene: SKScene {
    
    // Constants
    private let SpaceShipNodeName = "ship"
    private let PhotonTorpedoName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HUDNodeName = "hud"
    
    private let ShipHealthRateNodeName = "shipHealth"
    private let ShipShieldNodeName = "shield"
    
    // Properties to hold sound actions. We will be preloading the sounds
    // into these properties so there is no delay when they are implemented
    // for the first time.
    private let shootSound = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    private let obstacleExplodedSound = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    private let shipExplodedSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
   
    private let defaultFireRate: Double = 0.5
    private let powerupDuration: TimeInterval = 5.0
   
    
    // We wil be using the explosion particle emitters over and over
    // We dont want to load them from the .sks files everytime we need them,
    // so instead we'll create properties and load (cache) them for quick reuse
    // much like we did for our sound properties.
    
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("obstacleExplode.sks")!
    
    
    // Variables
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    private var shipFireRate: Double = 5.0
    
    
    // Create property named shipHealthReate of type Double to
    // keep track of your ships batter readiness. When the property reaches
    // zero, your ship will explode the next time it collides with an obstacle.
    private var shipHealthRate: Double = 2.0
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init (coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Called automatically when a touch begins
        if let touch = touches.first {
            /* let touchPoint = touch.location(in: self)
            
            // get a reference to our ship
            if let ship =  self.childNode(withName: SpaceShipNodeName) {
                ship.position = touchPoint // re-position the ship
            }*/
            
            self.shipTouch = touch
        }
        
    }
    
    func setupGame(_ size: CGSize) {
    
    let ship = SKSpriteNode(imageNamed: "Spaceship.png")
    ship.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
    ship.size = CGSize(width: 40.0, height: 40.0)
    ship.name = SpaceShipNodeName
    addChild(ship)
    
        // Add the star field parallax effect to the scene by creating
        // an instance of our StarFiled class and adding ti as a child or our scene.
        addChild(StarField())
        
    // Add ship thruster particle effect to our ship
        if let thrust = SKEmitterNode.nodeWithFile("thrust.sks") {
            
            thrust.position = CGPoint(x: 0.0, y: -20.0)
            
            // Now add the thrust as a child of our ship sprite
            // so its position is relative the ships postions.
            
            ship.addChild(thrust)
        }
        
        // Setup our HUD
        let hudNode = HUDNode()
        hudNode.name = HUDNodeName
        
        // By default, nodes will overlap (stack) according to the order in which
        // they were added to the scene. If we wish to alter the stacking order
        // we can use a nodes zPosition property to do so.
        hudNode.zPosition = 100.0
        
        // set the postion of the HUD node to be at the center of the screen (scene).
        // All of the child nodes we will add to the HUD node will be positioned
        //
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        addChild(hudNode)
        
        hudNode.layoutForScene()
        
        // Start the game
        hudNode.startGame()
        
        
        
    }
        
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame was rendered
        let timeDelta = currentTime - lastUpdateTime
        
        
        if let shipTouch = shipTouch {
            
            /*if let ship =  self.childNode(withName: SpaceShipNodeName) {
                ship.position = shipTouch.location(in: self) // re-position the ship
            }*/
            
            moveShipTowardPoint(shipTouch.location(in: self), timeDelta: timeDelta)
            
            if currentTime - lastShotFireTime > shipFireRate {
                shoot()
                
                lastShotFireTime = currentTime
            }
        }
        
        // Release asteriods 1.5% of the time the frame is drawn. Note that this
        // number can be changed to increase game difficulty
        if arc4random_uniform(1000) <= 15 {
            dropThing()
            
        }
        // Collision dection
        checkCollisions()
        
        lastUpdateTime = currentTime
        
    }
    
    func moveShipTowardPoint(_ point: CGPoint, timeDelta: TimeInterval) {
        
        // Points per second the ship should travel
        let shipSpeed = CGFloat(230)
        
        if let ship =  self.childNode(withName: SpaceShipNodeName) {
            
            // Determine the distance between the ship's current postion and
            // the touch point (passed-in) using the Pythagorean Theorem.
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            // if distance remaining is greater than 4 points, keep moving the ship
            // towards the touch point. Otherwise, stop the ship. If we dont stop
            // the ship, it may jitter around the touch point due to imprecision
            // in floating point numbers.
            if distanceLeftToTravel > 4 {
                
                // Calculate how far we should move the ship during this frame.
                let distanceRemaining = CGFloat(timeDelta) * shipSpeed
                
                // Convert the distance remaining back into (x,y) coordinates
                // using atan2() to determine the proper angle based on the ships
                // position and destination (touch point).
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                // Then using the angel along with sin() and cos() functions
                // determine the x and y offset values (distances to move along thsese
                // axes.
                let xOffset = distanceRemaining * cos(angle)
                let yOffset = distanceRemaining * sin(angle)
                
                // Use the offset values to reposition the ship for this frame
                // moving it a little closer to the touch point.
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                
            }

         }
        
    }
    
    //
    // Shoot a photon torpedo
    //
    func shoot() {
        
        if let ship  = self.childNode(withName: SpaceShipNodeName) {
            
            // Create our photon torepedo sprite code
            let photon = SKSpriteNode(imageNamed: PhotonTorpedoName)
            
            photon.name = PhotonTorpedoName
            photon.position = ship.position
            self.addChild(photon)
            
            // Set up actions for the photon sprite
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
            
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            self.run(self.shootSound)
        }
        
    }
 
    //
    // Drop somthing from top of scene
    //
    func dropThing() {
        
        //Simulate a die roll from 0 -99
        let dieRoll = arc4random_uniform(100)
        
        if dieRoll < 15 {
            dropPowerUp()
        } else if dieRoll < 25 {
            dropEnemyShip()
            
        } else if dieRoll < 3 {
            // Drop a health power-up onto the scene by calling a method
            // named dropHealth in the dropThing method.
            dropHealth()
            
        } else {
            dropAsteroid()
        }

    }
    
    
    //
    // Drop an asteroid obstacle onto the scene
    //
    func dropAsteroid() {
        
        // Define asteroid size. Random Number between 15 and 44
        let sideSize =  Double(15 + arc4random_uniform(30))
        // maximum x-position for the scene
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        // Determin random starting point for the asteroid
        let startX = Double(arc4random_uniform(UInt32(maxX + (quarterX*2)))) - quarterX
        let startY = Double(self.size.height) + sideSize // above top edge of scene
        
        // Determine ending position of asteroid
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize // below bottom edge of scene
        
        //create asteroid sprite
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Get the asteroid moving
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(3 + arc4random_uniform(5)))
        
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Rotate the asteroi by 3 radians (just less than 180 degree) over a 1-3 duration
        let spin = SKAction.rotate(byAngle: 3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatForever(spin)
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.run(all)
        
    }
    
    //
    // Srop a weapons powerup
    //
    func dropPowerUp() {
        
        // Create a power-up sprite spinning and moving from top to bottom of screen
        let sideSize = 30.0
        
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        // Create power sprite ands set its properties
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        let powerUpPath = createBezierPath()
        
        // Actions for the Sprite
        powerUp.run(SKAction.sequence([SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0), SKAction.removeFromParent()]))
        
    }
    
    
    //
    // Drop Enemy Ship
    //
    func dropEnemyShip() {
        
        // Define enemy ship size
        let sideSize =  30.0
        
        // Determine random starting point for the asteroid
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 40)) + 20)
        let startY = Double(self.size.height) + sideSize // above top edge of scene
        
        
        //create asteroid sprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        // Get the enemy ship moving
        let shipPath = createBezierPath()
        
        // performa ction to fly our ship along the path
        //
        // asOffeet: a true value lets us treat the action point values of the path as offsets
        // from the enemy ships startng point. A false value would the tread the paths
        // points as absolute positons on the screen.
        //
        // orientToPath: true cause the enemy ship to turn and face the direction
        // of the path automatially
        
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        enemy.run(SKAction.sequence([followPath, SKAction.removeFromParent()]))
        
    }
    
    //
    // func build enemy ship movement
    //
    func createBezierPath() -> CGPath {
        
        let yMax = -1.0 * self.size.height
        
        // Bezier path uses two control points along a line to create
        // a curve path. We will us the UIBezierPath class to build this kind of object
        //
        // Bezier path produced using the PaintCode app (www.paintcodeapp.com)
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5, y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32, y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: 63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        //bezierPath.addCurveToPoint(CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
    }
    
    // Check for collision
    func checkCollisions() {
        if let ship = self.childNode(withName: SpaceShipNodeName) {
            
            // If the ship bumps into the power up remove the power up from the scene
            // and reset the shipFireRate to 0.1 to increase the ship's firing rate
            enumerateChildNodes(withName: PowerupNodeName) {
                powerUp, _ in
                
                if ship.intersects(powerUp) {
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        
                        hud.showPowerupTimer(self.powerupDuration)
                        
                    }
                    
                    // powerUp go away
                    
                    powerUp.removeFromParent()
                    
                    // Increase ship's firing rate
                    self.shipFireRate = 0.1
                    
                    // But, we need to power back down after a short delay
                    // so we are not unbeatable == boring
                    let powerDown = SKAction.run{
                        self.shipFireRate = self.defaultFireRate
                    }
                    
                    // Now lets setup a delay before the powerUp occurs.
                    let wait = SKAction.wait(forDuration: self.powerupDuration)
                    
                    //ship.run(SKAction.sequence([wait, powerDown]))
                    
                    // If we collect and additional power up while one is already
                    // in progress, we need to stop the one in progress and start
                    // a new on so we always get the full duration for the new one.
                    //
                    // Sprite Kit lets us run action with a key that we can then
                    // use to identify and remove the action before it has a chance
                    // to run or before it finishes if it is already running.
                    //
                    //If no key is found,, nothing happens
                    //
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    
                    ship.run(SKAction.sequence([wait, powerDown]), withKey: powerDownActionKey)
                    
                }
                
            }
            
            
            // Loop through all instances of obstacles in the Scene Graph node tree
            enumerateChildNodes(withName: ObstacleNodeName) {
                obstacle, _ in
                
                if ship.intersects(obstacle) {
                        
                    self.shipHealthRate -= 1
                    obstacle.removeFromParent()
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        //hud.createShipHealthGroup()
                        hud.showHealth(self.shipHealthRate)
                    }
                    
                    
                    if self.shipHealthRate == 0 {
                        // Ship, obastacel, and touch go away
                        self.shipTouch = nil
                        
                        // We need to call the copy() method on the shipExplodeTemplate node
                        // because nodes can only be added to a scene once.
                        //
                        // If we try to add a node again that already exists in a scene,
                        // the game will crash with an error. We will use the emitter node
                        // template inour cached property as a template from which to make
                        // copies.
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = ship.position
                        explosion.dieOutInDuration(0.3)
                        self.addChild(explosion)
                        
                        ship.removeFromParent()
                        
                        obstacle.removeFromParent()
                        
                        self.run(self.shipExplodedSound)
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            
                            hud.endGame()
                    }
                  }
                }
                // NOte: need to use self to reference our class because we are
                //inside a closure that affects scope.
                self.enumerateChildNodes(withName: self.PhotonTorpedoName) {
                    myPhoton, stop in
                    
                    if myPhoton.intersects(obstacle) {
                        
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        
                        self.run(self.obstacleExplodedSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        explosion.dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                        // Udpate our score
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            
                            hud.addPoints(100)
                            
                        }
                        
                        // This is like a break statement
                        stop.pointee = true
                    }
                }
            }
            
            // If the ship collided with on of our health power-ups.
            enumerateChildNodes(withName: ShipHealthRateNodeName) {
                shipHealth,_ in
               
                if ship.intersects(shipHealth) {
                    
                    shipHealth.removeFromParent()
                    self.shipHealthRate = 4.0
                    
                   
                }
                if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                    //hud.createShipHealthGroup()
                    hud.showHealth(self.shipHealthRate)
                }
                
            }
          
            
            
        }
    }
    
    //
    // Impelement the dropHealth method at the bottom of your Game.Scene.swift file.
    func dropHealth() {
        
        // Create the health power-up to start above the screen and travel down until it
        // collides with the ship or moves off the bottom of the screen.
        let sideSize = 20.0
        
        // maximum x-position for the scene
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        // Starting point of the shipHealth
        let startX = Double(arc4random_uniform(UInt32(maxX + (quarterX*2)))) - quarterX
        let startY = Double(self.size.height) + sideSize // above top edge of scene
        
        // Determine ending position of shipHealth
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize // below bottom edge of scene
        
        // Create health sprite ands set its properties
        let shipHealth = SKSpriteNode(imageNamed: "healthPowerUp")
        
        shipHealth.size = CGSize(width: sideSize, height: sideSize)
        shipHealth.position = CGPoint(x: startX, y: startY)
        shipHealth.name = ShipHealthRateNodeName
        
        // Add shiphealth to scene.
        self.addChild(shipHealth)
        
        // Move ship towards the bottom of the screen over a duration of 5 secounds
        // be removed after it moves off screen and scale down to 50% and fade out
        // as it moves towards the bottom of the screen.
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 5.0)
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        let scale = SKAction.scale(to: 0.50, duration: 5.0)
        let fadeOut = SKAction.fadeOut(withDuration: 5.0)
        
        let all = SKAction.group([travelAndRemove, scale, fadeOut])
        
        shipHealth.run(all)
       
    }
    
}





















