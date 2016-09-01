//
//  Image.swift
//  OpenGLES2DDemo
//
//  Created by Chris Bateman on 2016-08-19.
//  Copyright © 2016 Chris Bateman. All rights reserved.
//

import GLKit
import OpenGLES

/**
    Base class for all images.
 */
class Image {
    
    var textureInfo: GLKTextureInfo? = nil
    var program: GLuint = 0
    
    var samplerLocation: GLint = 0
    var mvpMatrixLocation: GLint = 0
    
    var verticesData: [GLfloat] = []
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    init() {
    }
    
    /**
        Setup resources.
     */
    func setupData() {
        let vertexShaderCode =
            "uniform mat4 uMVPMatrix;" +
            "attribute vec4 aPosition;" +
            "attribute vec2 aTexCoord;" +
            "varying vec2 vTexCoord;" +
            "void main() {" +
            "    gl_Position = uMVPMatrix * aPosition;" +
            "    vTexCoord = aTexCoord;" +
            "}"
        
        let fragmentShaderCode =
            "precision mediump float;" +
            "varying vec2 vTexCoord;" +
            "uniform sampler2D sTexture;" +
            "void main() {" +
            "    gl_FragColor = texture2D(sTexture, vTexCoord);" +
            "}"
        
        // Create program from shaders
        program = loadProgram(vertexShaderCode, fragmentShaderCode)
        
        // Get locations
        samplerLocation = glGetUniformLocation(program, "sTexture")
        mvpMatrixLocation = glGetUniformLocation(program, "uMVPMatrix")
        
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(sizeof(GLfloat) * verticesData.count), &verticesData, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 20, BUFFER_OFFSET(0))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.TexCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.TexCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 20, BUFFER_OFFSET(12))
        
        glBindVertexArrayOES(0)
    }
    
    /**
        Draws an image using mvpMatrix to position image.
     
        - Parameters:
            - mvpMatrix: the Model View Projection matrix to position image
     */
    func draw(inout mvpMatrix: GLKMatrix4) {
        glBindVertexArrayOES(vertexArray)
        
        glUseProgram(program)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(textureInfo!.target, textureInfo!.name)
        glUniform1i(samplerLocation, 0)
        
        withUnsafePointer(&mvpMatrix, {
            glUniformMatrix4fv(mvpMatrixLocation, 1, 0, UnsafePointer($0))
        })
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
    }
    
    /**
        Cleanup any resources.
     */
    func cleanUp() {
        if let texInfo = textureInfo {
            var name = texInfo.name
            glDeleteTextures(1, &name)
        }
        
        if vertexBuffer != 0 {
            glDeleteBuffers(1, &vertexBuffer)
            vertexBuffer = 0
        }
        
        if vertexArray != 0 {
            glDeleteVertexArraysOES(1, &vertexArray)
            vertexArray = 0
        }
        
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
    }
    
    /**
     Load texture from file (of type). File should be part of project.
     
        - Parameters:
            - file: Name of texture file.
            - type: Type of texture file.
        - Returns: GLKTextureInfo object or nil if error occurs
     */
    func loadTexture(file: String, _ type: String) -> GLKTextureInfo {
        let imagePathname = NSBundle.mainBundle().pathForResource(file, ofType: type)!
        
        var textureInfo: GLKTextureInfo? = nil
        do {
            try textureInfo = GLKTextureLoader.textureWithContentsOfFile(imagePathname, options: [:])
        } catch {
            print("Could not create texture info for image [reason: ", error, "]")
        }
        
        return textureInfo!
    }
    
    func validateProgram(prog: GLuint) -> Bool {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](count: Int(logLength), repeatedValue: 0)
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            print("Program validate log: \n\(log)")
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    }
    
    /**
     Loads vertex and fragment shaders, creates program object, links program, returns
     program id.
     
        - Parameters:
            - vShaderCode: Vertex shader code as string.
            - fShaderCode: Fragment shader as string.
        - Returns: Program id of created program or 0 if error occurs.
     */
    func loadProgram(vShaderCode: String, _ fShaderCode: String) -> GLuint {
        var program: GLuint = 0
        var vertShader: GLuint = 0
        var fragShader: GLuint = 0
        var status: GLint = 0
        
        vertShader = loadShader(GLenum(GL_VERTEX_SHADER), vShaderCode)
        if vertShader == 0 {
            return 0
        }
        
        fragShader = loadShader(GLenum(GL_FRAGMENT_SHADER), fShaderCode)
        if fragShader == 0 {
            glDeleteShader(vertShader)
            return 0
        }
        
        program = glCreateProgram()
        if program == 0 {
            glDeleteShader(vertShader)
            glDeleteShader(fragShader)
            return 0
        }
        
        glAttachShader(program, vertShader)
        glAttachShader(program, fragShader)
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Position.rawValue), "aPosition")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.TexCoord0.rawValue), "aTexCoord")
        
        glLinkProgram(program)
        
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            var logLength: GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
                glGetProgramInfoLog(program, logLength, &logLength, log)
                print("Program link log: ", log)
                free(log)
            }
            
            glDeleteProgram(program)
            return 0
        }
        
        if vertShader != 0 {
            glDetachShader(program, vertShader)
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDetachShader(program, fragShader)
            glDeleteShader(fragShader)
        }
        
        return program
    }
    
    /**
     Create, load and compile a shader of type.
     
        - Parameters:
            - type: The type of shader.
            - shaderCode: The shader code.
        - Returns: Shader id of created shader or 0 if error occurs.
     */
    func loadShader(type: GLenum, _ shaderCode: String) -> GLuint {
        var shader: GLuint = 0
        var status: GLint = 0
        
        shader = glCreateShader(type)
        if shader == 0 {
            return 0
        }
        
        var shaderCodeSource = (shaderCode as NSString).UTF8String
        glShaderSource(shader, GLsizei(1), &shaderCodeSource, nil)
        glCompileShader(shader)
        
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        
        if status == 0 {
            var logLength: GLint = 0
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
                glGetShaderInfoLog(shader, logLength, &logLength, log)
                print("Shader compile log: ", log)
                free(log)
            }
            
            glDeleteShader(shader)
            return 0
        }
        
        return shader
    }
}