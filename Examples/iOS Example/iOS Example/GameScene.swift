//
//  GameScene.swift
//  iOS Example
//
//  Created by Daniel Sarfati on 7/5/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import SpriteKit
import GameplayKit
import Zapic

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var button: SKNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        
        self.button = self.childNode(withName: "//zapicButton")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        // Check if the location of the touch is within the button's bounds
        if button!.contains(touchLocation) {
          Zapic.showDefaultPage();
        }
      Zapic.submitEvent(["Event123": 34,"Score":22])
      
      Zapic.handleInteraction(["zapic": "/challenge/123"])
      
      guard let player = Zapic.player else {
        return
      }
      
      let currentPlayer = Zapic.player
      let id = currentPlayer?.playerId
      
      //Update the label to show the player's id
      self.label?.text = "Hello player \(player.playerId)"
    }
}
