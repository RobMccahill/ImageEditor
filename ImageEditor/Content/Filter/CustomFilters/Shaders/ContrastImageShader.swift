//
//  ContrastImageShader.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

import MetalKit

class ContrastImageShader: MetalImageShader {
    let functionName: String = "contrast"
    var input: ContrastInput = ContrastInput(contrastFactor: 1.0)
    
    init(contrastFactor: ContrastInput = ContrastInput(contrastFactor: 1.0)) {
        self.input = contrastFactor
    }
    
    func makeBuffer(using device: MTLDevice) -> MTLBuffer? {
        return makeBuffer(from: &input, using: device)
    }
    
    func updateBuffer(_ buffer: MTLBuffer) {
        return updateBuffer(from: &input, buffer: buffer)
    }
}

struct ContrastInput {
    var contrastFactor: Float
}
