//
//  DirectionButton.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-29.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit

/**
    Clicking direction button changes direction of moon.
 */
class DirectionButton: Button {
    
    init(_ aspect: Float) {
        super.init()
        
        // Setup vertices data for direction image.
        verticesData = [
            -0.07, 0.07, 0.0,   // Position 0
            0.0, 0.0,           // TexCoord 0
            
            -0.07, -0.07, 0.0,  // Position 1
            0.0, 1.0,           // TexCoord 1
            
            0.07, -0.07, 0.0,   // Position 2
            1.0, 1.0,           // TexCoord 2
            
            0.07, 0.07, 0.0,    // Position 3
            1.0, 0.0            // TexCoord 3
        ]
        
        textureInfoArray.append(loadTexture("direction", "png"))
        textureInfo = textureInfoArray[0]
        
        for texInfo in textureInfoArray {
            glBindTexture(texInfo.target, texInfo.name)
        }
        
        translateMatrix = GLKMatrix4MakeTranslation((aspect - 0.15), (-1.0 + 0.15), 0.0)
        
        // Setup data after defining vertices and texture(s).
        setupData()
    }
}
