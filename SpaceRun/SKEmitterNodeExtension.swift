//
//  SKEmitterNodeExtension.swift
//  SpaceRun
//
//  Created by Bee Yang on 12/11/17.
//  Copyright © 2017 assignment2 Bee Yang. All rights reserved.
//

import SpriteKit

// .sks files are archieved in SKEmitterNode instances. Our manipulations (attribute changes)
// in the Xcode particle editor actually change the real properties on SKEmitterNode instances.
//
// We will need to retrieve a copy of that node from our app bundle. In order to
// mimic the API that Apple uses for sound actions, we will build a Swift extension to add
// a new method to the SKEmitterNode class.
//
// This is called a category in Objective-C, but is called an extension in Swift.

// Use a Swift extension to extend the String class to have a property named length.
extension String{
    var length: Int {
        return self.count
    }
}


extension SKEmitterNode {
    
    class func nodeWithFile(_ fileName: String) -> SKEmitterNode? {
        
        // Check the passed-in fileName to get its base file name and its extension.
        // If there is no extension, set it to "sks".
        let baseName = (fileName as NSString).deletingPathExtension
        
        var fileExtension = (fileName as NSString).pathExtension
        
        if fileExtension.length == 0 {
            fileExtension = "sks"
            
        }
        
        // Grab the main bundle of our app and ask for the path to a resource
        // that uses our baseName and fileExtension.
        if let path = Bundle.main.path(forResource: baseName, ofType: fileExtension) {
            
            // Particle effect file in Sprite are archived when they are created
            // so we need to unarchive the effecct file (.sks) so it can be treated
            // as an SKEmitterNode object.
            let node = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            
            return node
        }
        return nil
    }
    
    // We want to add explosions for the two collision sthat occur for tropedos vs obstacles
    // and obstacles vs ship
    //
    // We dont want the explosion emitter to run indefinitley so we will make them die out
    // after a short duration.
    //
    func dieOutInDuration(_ duration: TimeInterval) {
        
        // Define two waiting periods once we set the birthrate to zero
        // we will still need to wait before the already born particles die out.
        // Otherwise, the particles will simply vanish from the screen immdediatley.
        //
        let firstWait = SKAction.wait(forDuration: duration)
        
        // Set the birthrate to zero in order to makethe particle effect disappear
        // using an SKAction run code block.
        let stop = SKAction.run{
            [weak self] in
            
            if let weakSelf = self {
                weakSelf.particleBirthRate = 0
            }
        }
        
        // Set up a second wait time
        let secondWait = SKAction.wait(forDuration: TimeInterval(self.particleLifetime))
        
        run(SKAction.sequence([firstWait, stop, secondWait, SKAction.removeFromParent()]))
        
        
    }
    
}
