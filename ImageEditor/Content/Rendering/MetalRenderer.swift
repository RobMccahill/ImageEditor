//
//  MetalRenderer.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 20/03/2025.
//

import Metal
import MetalKit
import MetalPerformanceShaders

/// - Tag: Renderer
final class MetalRenderer: NSObject, MTKViewDelegate, ObservableObject {
    public let device: MTLDevice
    
    let commandQueue: MTLCommandQueue
    let initialTexture: MTLTexture
    let resourceProvider: MetalResourceProvider
    
    let inFlightSemaphore = DispatchSemaphore(value: 3)
    
    init(renderState: RenderState = .shared, resourceProvider: MetalResourceProvider) {
        self.device = renderState.device
        self.commandQueue = renderState.commandQueue
        self.initialTexture = resourceProvider.getInitialTexture()
        self.resourceProvider = resourceProvider
        super.init()
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable else { return }
        
        inFlightSemaphore.wait()
        
        commandBuffer.addCompletedHandler { _ in
            self.inFlightSemaphore.signal()
        }
        
        let drawableSize = view.drawableSize
        let intermediateTexture = resourceProvider.getIntermediateTexture(forView: view)
        
        resourceProvider.applyShaderPipeline(to: intermediateTexture, commandBuffer: commandBuffer, scaleToSize: drawableSize)
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: intermediateTexture, to: drawable.texture)
        blitEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Respond to drawable size or orientation changes.
    }
}

class ShaderPipeline {
    let library: MTLLibrary
    let shaderPasses: [ShaderPass]
    
    init(device: MTLDevice, library: MTLLibrary, shaders: [MetalImageShader]) {
        self.library = library
        self.shaderPasses = shaders.map { shader in
            return ShaderPass(library: library, device: device, shader: shader)
        }
    }
    
    func apply(to texture: MTLTexture, buffer: MTLCommandBuffer) {
        for shaderPass in shaderPasses {
            let encoder = buffer.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(shaderPass.pipelineState)
            
            //TODO: Test in-place texture modification on more devices
            encoder.setTexture(texture, index: 0)
            encoder.setTexture(texture, index: 1)
            
            shaderPass.shader.updateBuffer(shaderPass.buffer)
            encoder.setBuffer(shaderPass.buffer, offset: 0, index: 0)
            
            let threadExecutionWidth = shaderPass.pipelineState.threadExecutionWidth
            let threadExecutionHeight = shaderPass.pipelineState.maxTotalThreadsPerThreadgroup / threadExecutionWidth
            
            let threadsPerGroup = MTLSizeMake(threadExecutionWidth, threadExecutionHeight, 1)
            let threadsPerGrid = MTLSizeMake(Int(texture.width), Int(texture.height), 1)
            
            //TODO: Look at alternative method for thread groups to ensure better compatibility
            encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
            encoder.endEncoding()
        }
    }
}

class ShaderPass {
    let shader: MetalImageShader
    let pipelineState: MTLComputePipelineState
    let buffer: MTLBuffer
    
    init(shader: MetalImageShader, pipelineState: MTLComputePipelineState, buffer: MTLBuffer) {
        self.shader = shader
        self.pipelineState = pipelineState
        self.buffer = buffer
    }
    
    convenience init(library: MTLLibrary, device: MTLDevice, shader: MetalImageShader) {
        let function = library.makeFunction(name: shader.functionName)!
        let pipelineState = try! device.makeComputePipelineState(function: function)
        let buffer = shader.makeBuffer(using: device)!
        self.init(shader: shader, pipelineState: pipelineState, buffer: buffer)
    }
}
