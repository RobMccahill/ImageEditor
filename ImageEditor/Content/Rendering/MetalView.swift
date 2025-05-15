//
//  MetalView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 28/01/2025.
//

import SwiftUI
import MetalKit

struct MetalView: ViewRepresentable {
    
    @StateObject var renderer: MetalRenderer
    
    /// - Tag: MakeView
    func makeView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: renderer.device)

        // Suggest to Core Animation, through MetalKit, how often to redraw the view
        view.preferredFramesPerSecond = 60

        // Allow rendering using the Metal compute pipeline
        view.framebufferOnly = false
        view.delegate = renderer
        
        return view
    }
    
    func updateView(_ view: MTKView, context: Context) {
        view.delegate = renderer
    }
}
