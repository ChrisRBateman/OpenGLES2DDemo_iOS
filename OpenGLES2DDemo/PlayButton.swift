//
//  PlayButton.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-29.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit

/**
    Clicking play button starts and stops moon.
 */
class PlayButton: Button {

    override init() {
        super.init()
        
        // Setup vertices data for speed image.
        verticesData = [
            -0.07, 0.07, 0.0,   // Position 0
            0.0, 0.0,           // TexCoord 0
            
            -0.07, -0.07, 0.0,  // Position 1
            0.0, 1.0,           // TexCoord 1
            
            0.07, -0.07, 0.0,   // Position 2
            1.0, 1.0,           // TexCoord 2
            
            -0.07, 0.07, 0.0,   // Position 0
            0.0, 0.0,           // TexCoord 0
            
            0.07, -0.07, 0.0,   // Position 2
            1.0, 1.0,           // TexCoord 2
            
            0.07, 0.07, 0.0,    // Position 3
            1.0, 0.0            // TexCoord 3
        ]
        
        textureInfoArray.append(loadTexture("play", "png"))
        textureInfoArray.append(loadTexture("pause", "png"))
        textureInfo = textureInfoArray[0]
        
        for texInfo in textureInfoArray {
            glBindTexture(texInfo.target, texInfo.name)
        }
        
        translateMatrix = GLKMatrix4MakeTranslation(0.0, (-1.0 + 0.15), 0.0)
        
        // Setup data after defining vertices and texture(s).
        setupData()
    }
}
