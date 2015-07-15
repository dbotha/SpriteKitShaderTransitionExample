//
//  SKScene+ShaderTransition.swift
//  ShaderSceneTransitionExample
//
//  Created by Deon Botha on 15/07/2015.
//  Copyright (c) 2015 Deon Botha. All rights reserved.
//

import Foundation
import SpriteKit

//private let totalAnimationDuration = 1.0
private let kNodeNameTransitionShaderNode = "kNodeNameTransitionShaderNode"
private let kNodeNameFadeColourOverlay = "kNodeNameFadeColourOverlay"
private var presentationStartTime: CFTimeInterval = -1
private var shaderChoice = -1

extension SKScene {
    
    private var transitionShader: SKShader? {
        get {
            if let shaderContainerNode = self.childNodeWithName(kNodeNameTransitionShaderNode) as? SKSpriteNode {
                return shaderContainerNode.shader
            }
            
            return nil
        }
    }
    
    private func createShader(shaderName: String, transitionDuration: NSTimeInterval) -> SKShader {
        var shader = SKShader(fileNamed:shaderName)
        var u_size = SKUniform(name: "u_size", floatVector3: GLKVector3Make(Float(UIScreen.mainScreen().scale * size.width), Float(UIScreen.mainScreen().scale * size.height), Float(0)))
        var u_fill_colour = SKUniform(name: "u_fill_colour", floatVector4: GLKVector4Make(131.0 / 255.0, 149.0 / 255.0, 255.0 / 255.0, 1.0))
        var u_border_colour = SKUniform(name: "u_border_colour", floatVector4: GLKVector4Make(104.0 / 255.0, 119.0 / 255.0, 204.0 / 255.0, 1.0))
        var u_total_animation_duration = SKUniform(name: "u_total_animation_duration", float: Float(transitionDuration))
        var u_elapsed_time = SKUniform(name: "u_elapsed_time", float: Float(0))
        shader.uniforms = [u_size, u_fill_colour, u_border_colour, u_total_animation_duration, u_elapsed_time]
        return shader
    }
    
    func presentScene(scene: SKScene?, shaderName: String, transitionDuration: NSTimeInterval) {
        // Create shader and add it to the scene
        var shaderContainer = SKSpriteNode(imageNamed: "dummy")
        shaderContainer.name = kNodeNameTransitionShaderNode
        shaderContainer.zPosition = 9999 // something arbitrarily large to ensure it's in the foreground
        shaderContainer.position = CGPointMake(size.width / 2, size.height / 2)
        shaderContainer.size = CGSizeMake(size.width, size.height)
        shaderContainer.shader = createShader(shaderName, transitionDuration:transitionDuration)
        self.addChild(shaderContainer)
        
        // remove the shader from the scene after its animation has completed.
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(transitionDuration * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            var fadeOverlay = SKShapeNode(rect: CGRectMake(0, 0, self.size.width, self.size.height))
            fadeOverlay.name = kNodeNameFadeColourOverlay
            fadeOverlay.fillColor = SKColor(red: 131.0 / 255.0, green: 149.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            fadeOverlay.zPosition = shaderContainer.zPosition
            scene!.addChild(fadeOverlay)
            self.view!.presentScene(scene)
        })
        
        // Reset the time presentScene was called so that the elapsed time from now can
        // be calculated in updateShaderTransitions(currentTime:)
        presentationStartTime = -1
    }
    
    func updateShaderTransition(currentTime: CFTimeInterval) {
        if let shader = self.transitionShader {
            let elapsedTime = shader.uniformNamed("u_elapsed_time")!
            if (presentationStartTime < 0) {
                presentationStartTime = currentTime
            }
            elapsedTime.floatValue = Float(currentTime - presentationStartTime)
        }
    }
    
    
    // this function is called by the scene being transitioned to when it's ready to have the view faded in to the scene i.e. loading is complete, etc.
    func completeShaderTransition() {
        if let fadeOverlay = self.childNodeWithName(kNodeNameFadeColourOverlay) {
            fadeOverlay.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.3), SKAction.removeFromParent()]))
        }
    }
    
    
    
}