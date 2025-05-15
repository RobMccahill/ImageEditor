//
//  RenderState.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 12/05/2025.
//

import CoreImage
import Metal
import MetalKit

struct RenderState {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let ciContext: CIContext
    
    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        // - Name the context to make CI_PRINT_TREE debugging easier.
        // - Disable caching because the image differs every frame.
        // - Allow the context to use the low-power GPU, if available.
        ciContext = CIContext(mtlCommandQueue: commandQueue,
                              options: [.name: "Renderer",
                                        .cacheIntermediates: false,
                                        .allowLowPower: true])
    }
}

extension RenderState {
    static let shared = RenderState()
}

extension MTKView {
    var scaleFactor: CGFloat {
#if os(macOS)
        // Determine the scale factor converting a point size to a pixel size.
        return self.convertToBacking(CGSize(width: 1.0, height: 1.0)).width
#else
        return self.contentScaleFactor
#endif
    }
}
