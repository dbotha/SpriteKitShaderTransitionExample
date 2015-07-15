//
//  GameScene2.swift
//  ShaderSceneTransitionExample
//
//  Created by Deon Botha on 15/07/2015.
//  Copyright (c) 2015 Deon Botha. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene2: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = SKColor.whiteColor()
        
        var label = SKLabelNode(text: "Scene 2")
        label.fontColor = SKColor.blackColor()
        label.fontSize = 32
        label.position = CGPointMake(size.width / 2, size.height / 2)
        self.addChild(label)
        
        label = SKLabelNode(text: "tap to transition")
        label.fontColor = SKColor.blackColor()
        label.fontSize = 24
        label.position = CGPointMake(size.width / 2, size.height / 2 - 50)
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        // fake some loading delay then finish the shader transition
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            self.completeShaderTransition()
        })
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.presentScene(GameScene(size: self.size), shaderName: "retro_transition_fade_from_centre.fsh", transitionDuration: 1.0)
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.updateShaderTransition(currentTime)
    }
}
