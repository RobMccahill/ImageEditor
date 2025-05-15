//
//  ExposureImageShader.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

import Foundation

import MetalKit

class ExposureImageShader: MetalImageShader {
    let functionName: String = "exposure"
    var input: ExposureInput = ExposureInput(exposureFactor: 1.0)
    
    init(saturationFactor: ExposureInput = ExposureInput(exposureFactor: 1.0)) {
        self.input = saturationFactor
    }
    
    func makeBuffer(using device: MTLDevice) -> MTLBuffer? {
        return makeBuffer(from: &input, using: device)
    }
    
    func updateBuffer(_ buffer: MTLBuffer) {
        return updateBuffer(from: &input, buffer: buffer)
    }
}

struct ExposureInput {
    var exposureFactor: Float
}
