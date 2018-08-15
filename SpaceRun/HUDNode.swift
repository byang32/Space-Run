//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Bee Yang on 12/11/17.
//  Copyright © 2017 assignment2 Bee Yang. All rights reserved.
//

import SpriteKit

class HUDNode: SKNode {
    
    // Create a Heads-UP-Display (HUD)  that will hold all of our display areaas
    //
    // Once the node is added to the scene, we'll tell it to lay out its child
    // nodes. The child nodes will not contain labels as we will use the blank
    // nodes as group contrainers and layo ut the label nodes insdie of them.
    //
    // We will left-align our Score and right-align the elapsed game time.
    //
    
    // Build two parent nodes (containers) that will hold the score
    // and value labels.
    
    // Properties
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    
    private let ElapsedGroupName =  "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerupGroupName =  "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "powerupGameTimer"
    
    private let ShowHealthGroupName = "showHealthGroup"
    private let ShowHealthValueName = "showHealthValue"

    
    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    
    var health: Double = 2.0
        
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override init() {
        super.init()
        createShipHealthGroup()
        createScoreGroup()
        createElapsedGroup()
        createPowerupGroup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Our labels are properly layed out within their parent group nodes,
    // but the group nodes are centered on the screen (scene). We need
    // to create a layout method that will properly position the groups.
    //
    func layoutForScene() {
        
        // When a node exists in the Scene Graph, it can get access to the scene
        // via its scene property. That property is nil if the node doesnt belong
        // to a scene yet, so this method is useless if the node is not yet added to the scene.
        if let scene = scene {
            
            let sceneSize = scene.size
            
            var groupSize = CGSize.zero
            
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 30, y: sceneSize.height/2.0 - groupSize.height)
    
            } else {
            
                assert(false, "No score group node was found in the Scene Graph node tree")
            }
        
            if let elapsedGroup = childNode(withName: ElapsedGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 30, y: sceneSize.height/2.0 - groupSize.height)

            } else {
            
                assert(false, "No score group node was found in the Scene Graph node tree")
            }
            
            if let powerupGroup = childNode(withName: PowerupGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                
                assert(false, "No powerup group node was found in the Scene Graph node tree")
            }
            
            if let showHealthGroup = childNode(withName: ShowHealthGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = showHealthGroup.calculateAccumulatedFrame().size
                
                showHealthGroup.position = CGPoint(x: 0.0, y: -sceneSize.height/2.0 + groupSize.height)
                
            } else {
                
                assert(false, "No powerup group node was found in the Scene Graph node tree")
            }
        }
        
    }
    
    
    func createScoreGroup() {
        
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Create an SKLabelNode for our title.
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels insdie this group node.
        
        scoreTitle.horizontalAlignmentMode = .center
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels insdie this group node.
        
        scoreValue.horizontalAlignmentMode = .center
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        // Add scoreGroup as a child of our HUD node.
        addChild(scoreGroup)
        
    }
    
    func createElapsedGroup() {
        
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        // Create an SKLabelNode for our title.
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels insdie this group node.
        
        elapsedTitle.horizontalAlignmentMode = .center
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = "TIME"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels insdie this group node.
        
        elapsedValue.horizontalAlignmentMode = .center
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        // Add scoreGroup as a child of our HUD node.
        addChild(elapsedGroup)
        
    }
    
    
    func createPowerupGroup() {
        
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        // Create an SKLabelNode for our title.
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels insdie this group node.
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Set up actions to  make our title pulse
        powerupTitle.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.3), SKAction.scale(to: 1.0, duration: 0.3)])))
        
        powerupGroup.addChild(powerupTitle)
        
        
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.red
        
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels insdie this group node.
        powerupValue.verticalAlignmentMode = .top
        powerupValue.name = PowerupValueName
        powerupValue.text = "0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerupGroup.addChild(powerupValue)
        
        // Add powerupGroup as a child of our HUD node.
        addChild(powerupGroup)
        
        powerupGroup.alpha = 0.0 // make it invisible to start
        
    }
    
    
    /// Function to update ScoreValue label in HUD
    ///
    /// - parameter points: Integer
    func addPoints(_ points: Int) {
        
        score += points
        
        // Update HUD by looking up scoreValue label and updating it
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            
            // Format our score value using the thousands of separator by using our
            //cached self.scorerFormatter property
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            // Scale the node up for brief period of time and then scale it back down.
            scoreValue.run(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.02), SKAction.scale(to: 1.0, duration: 0.07)]))
        }
        
    }
    
    func showPowerupTimer(_ time: TimeInterval) {
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            if let powerupValue = powerupGroup.childNode(withName: PowerupValueName) as! SKLabelNode? {
                
                // Run the countdown sequence
                let start = Date.timeIntervalSinceReferenceDate
                
                let block = SKAction.run {
                    [weak self] in
                    
                    if let weakSelf = self {
                        let elapsedTime = Date.timeIntervalSinceReferenceDate - start
                        
                        let timeLeft = max(time - elapsedTime, 0)
                        
                        let timeLeftFormat = weakSelf.timeFormatter.string(from: NSNumber(value: timeLeft))
                        
                        powerupValue.text = "\(timeLeftFormat ?? "0")s left"
                        
                        
                    }
                }
                
                let countDownSequence = SKAction.sequence([block, SKAction.wait(forDuration: 0.05)])
                
                let coundDown = SKAction.repeatForever(countDownSequence)
                
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                
                let stopAction = SKAction.run ({ () -> Void in
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                })
                
                let visuals = SKAction.sequence([fadeIn, SKAction.wait(forDuration: time), fadeOut, stopAction])
                
                powerupGroup.run(SKAction.group([coundDown, visuals]), withKey: self.PowerupTimerActionName)
            }
        }
        
    }
    
    
    /************************************************
     ***       Start of ShowHealth Methods        ***
     ***********************************************/
    // Create showHealth method to display a health bar on
    // the gamee scene.
    func createShipHealthGroup() {
        
    let showHealthGroup = SKNode()
    showHealthGroup.name = ShowHealthGroupName
    
    // Create an SKLabelNode for our title.
    let showHealthTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
    
    showHealthTitle.fontSize = 12.0
    showHealthTitle.fontColor = SKColor.white
    
    // Set the vertical and horizontal alignment modes in a way that will help
    // use layout for the labels insdie this group node.
    
    showHealthTitle.horizontalAlignmentMode = .center
    showHealthTitle.verticalAlignmentMode = .bottom
    showHealthTitle.text = "Health"
    showHealthTitle.position = CGPoint(x: 0.0, y: 4.0)
    
    showHealthGroup.addChild(showHealthTitle)
    
    let showHealthValue = SKLabelNode(fontNamed: "AvenirNext-Medium")
    
    showHealthValue.fontSize = 15.0
    showHealthValue.fontColor = SKColor.white
        
    // Set the vertical and horizontal alignment modes in a way that will help
    // use layout for the labels insdie this group node.
    
    showHealthValue.horizontalAlignmentMode = .center
    showHealthValue.verticalAlignmentMode = .top
    showHealthValue.name = ShowHealthValueName
    showHealthValue.text = "50.0%"
    showHealthValue.position = CGPoint(x: 0.0, y: -2.0)
    
    showHealthGroup.addChild(showHealthValue)
    
    // Add scoreGroup as a child of our HUD node.
    addChild(showHealthGroup)
    
    }
    
    func showHealth(_ damage: Double) {
    
        health -= damage
        if let shipHealthValue = childNode(withName: "\(ShowHealthGroupName)/\(ShowHealthValueName)") as! SKLabelNode? {
            
            let status = (100 * damage/4.0)
            shipHealthValue.text = "\(status)%"
        }
    
    }
    /*************************************************
     ***          End of ShowHealth Method         ***
     ************************************************/
    
    
    func startGame() {
        
        // Calculate the timestamp when starting the game.
        let startTime = Date.timeIntervalSinceReferenceDate
        
        if let elapsedValue = childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode? {
            
            // Use a code block to update the elapsedTime property to be the
            // different between the startTime and the current timeStamp
            let update = SKAction.run ({
                [weak self] in
                
                if let weakSelf = self {
                    
                    let currentTime = Date.timeIntervalSinceReferenceDate
                    
                    weakSelf.elapsedTime = currentTime - startTime
                    
                    elapsedValue.text = weakSelf.timeFormatter.string(from: NSNumber(value: weakSelf.elapsedTime))
                }
                
            })
            
            let updateAndDelay = SKAction.sequence([update, SKAction.wait(forDuration: 0.05)])
            
            let timer = SKAction.repeatForever(updateAndDelay)
            
            run(timer, withKey: TimerActionName)
        }
    }
    
    func endGame() {
        
        // Stop the timer sequence
        removeAction(forKey: TimerActionName)
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            powerupGroup.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
            
        }
    }
    
    
    
    
    
    
    
}
