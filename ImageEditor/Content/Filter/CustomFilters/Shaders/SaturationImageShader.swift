//
//  SaturationImageShader.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

import MetalKit

class SaturationImageShader: MetalImageShader {
    let functionName: String = "saturation"
    var input: SaturationInput = SaturationInput(saturationFactor: 1.0)
    
    init(saturationFactor: SaturationInput = SaturationInput(saturationFactor: 1.0)) {
        self.input = saturationFactor
    }
    
    func makeBuffer(using device: MTLDevice) -> MTLBuffer? {
        return makeBuffer(from: &input, using: device)
    }
    
    func updateBuffer(_ buffer: MTLBuffer) {
        return updateBuffer(from: &input, buffer: buffer)
    }
}

struct SaturationInput {
    var saturationFactor: Float
}
