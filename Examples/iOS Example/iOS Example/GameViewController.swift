//
//  GameViewController.swift
//  iOS Example
//
//  Created by Daniel Sarfati on 7/5/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let view = self.view as! SKView? {
      // Load the SKScene from 'GameScene.sks'
      if let scene = SKScene(fileNamed: "GameScene") {
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        view.presentScene(scene)
      }
      
      //view.ignoresSiblingOrder = true
      
      //view.showsFPS = true
      //view.showsNodeCount = true
      
    }
  }
  
  func showUrlDialog(){
    let ac = UIAlertController(title: "Enter Web Client URL", message: nil, preferredStyle: .alert)
    ac.addTextField(configurationHandler: nil)
    
    ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] _ in
      let url = ac.textFields![0]
      UserDefaults.standard.set(url.text, forKey: "ZAPIC_URL")
    })
    
    self.present(ac, animated: true, completion: nil)
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      print("shake")
      showUrlDialog()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
