//
//  MetalImageShader.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

import MetalKit

protocol MetalImageShader {
    var functionName: String { get }
    func makeBuffer(using device: MTLDevice) -> MTLBuffer?
    func updateBuffer(_ buffer: MTLBuffer)
}

extension MetalImageShader {
    func makeBuffer<Uniform>(from uniform: UnsafePointer<Uniform>, using device: MTLDevice) -> MTLBuffer {
        return device.makeBuffer(bytes: uniform, length: MemoryLayout<Uniform>.stride, options: [])!
    }
    
    func updateBuffer<Uniform>(from uniform: UnsafePointer<Uniform>, buffer: MTLBuffer) {
        buffer.contents().copyMemory(from: uniform, byteCount: MemoryLayout<Uniform>.stride)
    }
}
