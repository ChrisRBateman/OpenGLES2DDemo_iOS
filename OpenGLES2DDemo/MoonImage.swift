//
//  MoonImage.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-27.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit

/**
    Renders an image of moon.
 */
class MoonImage: Image {
    
    let MIN_SPEED: Float = 0.20
    
    let MAX_X: Float = 0.4
    let MIN_X: Float = -0.4
    
    var x: Float = 0.4
    var y: Float = -0.4
    var directionX = 1
    var directionY = -1
    var speed: Float = 0.20
    var zOrder = 1
    var isAnimating = false
    
    override init() {
        super.init()
        
        // Setup vertices data for moon image.
        verticesData = [
            -0.1, 0.1, 0.0,     // Position 0
            0.0, 0.0,           // TexCoord 0
            
            -0.1, -0.1, 0.0,    // Position 1
            0.0, 1.0,           // TexCoord 1
            
            0.1, -0.1, 0.0,     // Position 2
            1.0, 1.0,           // TexCoord 2
            
            0.1, 0.1, 0.0,      // Position 3
            1.0, 0.0            // TexCoord 3
        ]
        
        textureInfo = loadTexture("moon", "png")
        if let texInfo = textureInfo {
            glBindTexture(texInfo.target, texInfo.name)
        }
        
        // Setup data after defining vertices and texture(s).
        setupData()
    }
    
    /**
        Update image location.
     
        - Parameters:
            - timeDeltaSeconds: time delta
     */
    func update(_ timeDeltaSeconds: Float) {
        if isAnimating {
            x = x + (Float(directionX) * speed * timeDeltaSeconds)
            y = y + (Float(directionY) * speed * timeDeltaSeconds)
    
            if (x > MAX_X) || (x < MIN_X) {
                directionX = -directionX
                directionY = -directionY
                zOrder = -zOrder
                x = max(-0.4, min(x, 0.4))
                y = max(-0.4, min(y, 0.4))
            }
        }
    }
    
    /**
        Change moon direction.
     */
    func changeDirection() {
        if (MIN_X <= x) && (x <= MAX_X) {
            directionX = -directionX;
            directionY = -directionY;
        }
    }
    
    /**
        Change moon speed.
     */
    func changeSpeed() {
        if (MIN_X <= x) && (x <= MAX_X) {
            if (speed == MIN_SPEED) {
                speed = 2 * MIN_SPEED
            } else if (speed == 2 * MIN_SPEED) {
                speed = 3 * MIN_SPEED
            } else {
                speed = MIN_SPEED
            }
        }
    }
}
