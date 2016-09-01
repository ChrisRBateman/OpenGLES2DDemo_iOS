//
//  GameViewController.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-18.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit
import OpenGLES

func BUFFER_OFFSET(i: Int) -> UnsafePointer<Void> {
    let p: UnsafePointer<Void> = nil
    return p.advancedBy(i)
}

class GameViewController: GLKViewController {
    
    let pi = M_PI
    
    var context: EAGLContext? = nil
    
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    var viewMatrix: GLKMatrix4 = GLKMatrix4Identity
    var pvMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    var moonMatrix: GLKMatrix4 = GLKMatrix4Identity
    var scaleMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    var starsImage: StarsImage? = nil
    var earthImage: EarthImage? = nil
    var moonImage: MoonImage? = nil
    
    var speedButton: SpeedButton? = nil
    var playButton: PlayButton? = nil
    var directionButton: DirectionButton? = nil
    
    deinit {
        tearDownGL()
        
        if EAGLContext.currentContext() === context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        context = EAGLContext(API: .OpenGLES2)
        
        if !(context != nil) {
            print("Failed to create ES context")
        }
        
        let view = self.view as! GLKView
        view.context = context!
        view.drawableDepthFormat = .Format24
        
        setupGL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if isViewLoaded() && (view.window != nil) {
            view = nil
            
            tearDownGL()
            
            if EAGLContext.currentContext() === context {
                EAGLContext.setCurrentContext(nil)
            }
            context = nil
        }
    }
    
    override func prefersStatusBarHidden () -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            var location = touch.locationInView(view)
            let scale = UIScreen.mainScreen().scale
            
            location.x *= scale
            location.y *= scale
            
            var viewport: [Int32] = [Int32](count: Int(4), repeatedValue: 0)
            glGetIntegerv(GLenum(GL_VIEWPORT), &viewport)
            
            if speedButton!.handleTouch(Float(location.x), Float(location.y), projectionMatrix, &viewport) {
                changeSpeed()
            } else if playButton!.handleTouch(Float(location.x), Float(location.y), projectionMatrix, &viewport) {
                togglePlay()
            } else if directionButton!.handleTouch(Float(location.x), Float(location.y), projectionMatrix, &viewport) {
                changeDirection()
            }
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    func setupGL() {
        EAGLContext.setCurrentContext(context)
        
        preferredFramesPerSecond = 60
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        starsImage = StarsImage()
        earthImage = EarthImage()
        moonImage = MoonImage()
        
        let aspect = fabsf(Float(view.bounds.size.width / view.bounds.size.height))
        
        speedButton = SpeedButton(aspect)
        playButton = PlayButton()
        directionButton = DirectionButton(aspect)
        
        projectionMatrix = GLKMatrix4MakeOrtho(-aspect, aspect, -1, 1, 3, 7)
        viewMatrix = GLKMatrix4MakeLookAt(0, 0, 3, 0, 0, 0, 0, 1.0, 0.0)
        pvMatrix = GLKMatrix4Multiply(projectionMatrix, viewMatrix)
    }
    
    func tearDownGL() {
        EAGLContext.setCurrentContext(context)
        
        starsImage!.cleanUp()
        earthImage!.cleanUp()
        moonImage!.cleanUp()
        
        speedButton!.cleanUp()
        playButton!.cleanUp()
        directionButton!.cleanUp()
    }
    
    // MARK: - GLKView and GLKViewController delegate methods
    
    func update() {
        moonImage!.update(Float(timeSinceLastUpdate))
        let matrix = GLKMatrix4MakeTranslation(moonImage!.x, moonImage!.y, 0.0)
        moonMatrix = GLKMatrix4Multiply(pvMatrix, matrix)
        
        let scaleValue = getButtonAnimationScaleValue(Float(timeSinceFirstResume))
        scaleMatrix = GLKMatrix4MakeScale(scaleValue, scaleValue, 1.0)
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        
        starsImage!.draw(&pvMatrix)
        
        if moonImage!.zOrder > 0 {
            earthImage!.draw(&pvMatrix)
            moonImage!.draw(&moonMatrix)
        } else {
            moonImage!.draw(&moonMatrix)
            earthImage!.draw(&pvMatrix)
        }
        
        speedButton!.draw(&pvMatrix, &scaleMatrix)
        playButton!.draw(&pvMatrix, &scaleMatrix)
        directionButton!.draw(&pvMatrix, &scaleMatrix)
    }
    
    // MARK: - Misc functions
    
    /**
        Change moon speed.
     */
    func changeSpeed() {
        if let image = moonImage {
            image.changeSpeed()
            
            if image.speed == image.MIN_SPEED {
                speedButton!.setCurrentImage(0)
            } else if image.speed == 2 * image.MIN_SPEED {
                speedButton!.setCurrentImage(1)
            } else {
                speedButton!.setCurrentImage(2)
            }
        }
    }
    
    /**
        Play/pause moon animation.
     */
    func togglePlay() {
        if let image = moonImage {
            image.isAnimating = !image.isAnimating
            if image.isAnimating {
                playButton!.setCurrentImage(1)
            } else {
                playButton!.setCurrentImage(0)
            }
        }
    }
    
    /**
        Change moon direction.
     */
    func changeDirection() {
        if let image = moonImage {
            image.changeDirection()
        }
    }
    
    /**
        Returns the current scale value.
     
        - Parameters:
            - timeDeltaSeconds: the time interval
        - Returns: the scale value
     */
    func getButtonAnimationScaleValue(timeDeltaSeconds: Float) -> Float {
        let min: Double = 1.0 - 0.04
        let max: Double = 1.0 + 0.04
        let period: Double = 0.5
        let phase: Double = 0.0
        
        let amplitude: Double = max - min
        let arg = ((Double(timeDeltaSeconds) / period) + phase) * 2 * pi
        return Float(min + amplitude * sin(arg))
    }
}

