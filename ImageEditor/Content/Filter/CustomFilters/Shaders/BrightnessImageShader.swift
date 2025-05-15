//
//  BrightnessImageShader.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

import MetalKit

class BrightnessImageShader: MetalImageShader {
    let functionName: String = "brightness"
    var input: BrightnessInput = BrightnessInput(brightnessFactor: 1.0)
    
    init(saturationFactor: BrightnessInput = BrightnessInput(brightnessFactor: 1.0)) {
        self.input = saturationFactor
    }
    
    func makeBuffer(using device: MTLDevice) -> MTLBuffer? {
        return makeBuffer(from: &input, using: device)
    }
    
    func updateBuffer(_ buffer: MTLBuffer) {
        return updateBuffer(from: &input, buffer: buffer)
    }
}

struct BrightnessInput {
    var brightnessFactor: Float
}
