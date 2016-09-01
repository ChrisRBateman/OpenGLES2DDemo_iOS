//
//  Button.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-28.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit

struct Rect {
    var top: Float
    var left: Float
    var bottom: Float
    var right: Float
    
    init() {
        top = 0.0
        left = 0.0
        bottom = 0.0
        right = 0.0
    }
}

/**
    Button extends Image class to display a button image. 
    Also provides support for user input.
 */
class Button: Image {
    
    var textureInfoArray = [GLKTextureInfo]()
    var translateMatrix: GLKMatrix4 = GLKMatrix4Identity
    var boundRect: Rect = Rect()
    
    override init() {
        super.init()
    }
    
    /**
        Setup resources.
     */
    override func setupData() {
        super.setupData()
        
        // verticesData and translateMatrix are setup in init.
        let vec1 = GLKVector4Make(verticesData[0], verticesData[1], verticesData[2], 1.0)
        let vec2 = GLKVector4Make(verticesData[10], verticesData[11], verticesData[12], 1.0)
        
        let res1 = GLKMatrix4MultiplyVector4(translateMatrix, vec1)
        let res2 = GLKMatrix4MultiplyVector4(translateMatrix, vec2)
        
        boundRect.left = res1.x
        boundRect.top = res1.y
        
        boundRect.right = res2.x
        boundRect.bottom = res2.y
    }
    
    /**
        Draws button using mvpMatrix and scaleMatrix to position button.
     
        - Parameters:
            - mvpMatrix: the Model View Projection matrix to position image
            - scaleMatrix: the Scaling matrix
     */
    func draw(inout mvpMatrix: GLKMatrix4, inout _ scaleMatrix: GLKMatrix4) {
        // Translate then scale
        let intermediate = GLKMatrix4Multiply(mvpMatrix, translateMatrix)
        var final = GLKMatrix4Multiply(intermediate, scaleMatrix)
        super.draw(&final)
    }
    
    /**
        Set the current image.
     
        - Parameters:
            - index: the index of image
     */
    func setCurrentImage(index: Int) {
        if (index >= 0) && (index < textureInfoArray.count) {
            textureInfo = textureInfoArray[index];
        }
    }
    
    /**
        Returns true if touch event handled.
     
        - Parameters:
            - x: the x coordinate
            - y: the y coordinate
            - pMatrix: projection matrix
            - viewport: screen dimensions
        - Returns: true if button handles touch; otherwise false
     */
    func handleTouch(x: Float, _ y: Float, _ pMatrix: GLKMatrix4, inout _ viewport: [Int32]) -> Bool {
        let newY: Float = Float(viewport[3]) - y
        let window = GLKVector3Make(x, newY, 1.0)
        var success: Bool = false
        
        let result = GLKMathUnproject(window, GLKMatrix4Identity, pMatrix, &viewport, &success)
        
        if success {
            return pointInRect(result.x, result.y, boundRect)
        }
        
        return false
    }
    
    /**
        Returns true if point is in rectangle.
     
        - Parameters:
            - x: x coordinate of point
            - y: y coordinate of point
            - r: the rectangle
        - Returns: true if point in rect; otherwise false
     */
    func pointInRect(x: Float, _ y: Float, _ r: Rect) -> Bool {
        return ((r.left <= x && x <= r.right) || (r.right <= x && x <= r.left)) &&
                ((r.top <= y && y <= r.bottom) || (r.bottom <= y && y <= r.top))
    }
    
    override func cleanUp() {
        for texInfo in textureInfoArray {
            var name = texInfo.name
            glDeleteTextures(1, &name)
        }
        
        textureInfo = nil
        super.cleanUp()
    }
}
