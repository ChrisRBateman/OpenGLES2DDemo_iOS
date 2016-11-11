//
//  EarthImage.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-27.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit

/**
    Renders an image of earth.
 */
class EarthImage: Image {
    
    override init() {
        super.init()
        
        // Setup vertices data for earth.
        verticesData = [
            -0.3, 0.3, 0.0,     // Position 0
            0.0, 0.0,           // TexCoord 0
            
            -0.3, -0.3, 0.0,    // Position 1
            0.0, 1.0,           // TexCoord 1
            
            0.3, -0.3, 0.0,     // Position 2
            1.0, 1.0,           // TexCoord 2
            
            0.3, 0.3, 0.0,      // Position 3
            1.0, 0.0            // TexCoord 3
        ]
        
        textureInfo = loadTexture("earth", "png")
        if let texInfo = textureInfo {
            glBindTexture(texInfo.target, texInfo.name)
        }
        
        // Setup data after defining vertices and texture(s).
        setupData()
    }
}