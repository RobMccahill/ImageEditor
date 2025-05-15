//
//  Renderer.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 28/01/2025.
//

//Based off the example provided in the apple documentation https://developer.apple.com/documentation/coreimage/generating_an_animation_with_a_core_image_render_destination

import CoreImage
import Metal
import MetalKit

/// - Tag: Renderer
final class CoreImageRenderer: NSObject, MTKViewDelegate, ObservableObject {
    typealias ImageProvider = (_ contentScaleFactor: CGFloat) -> CIImage
    
    public let device: MTLDevice
    
    let commandQueue: MTLCommandQueue
    let ciContext: CIContext
    let opaqueBackground: CIImage
    let imageProvider: ImageProvider
    let scaleMode: ScaleMode
    
    let inFlightSemaphore = DispatchSemaphore(value: 3)
    
    init(renderState: RenderState = .shared, scaleMode: ScaleMode = .scaleToFit, imageProvider: @escaping ImageProvider) {
        self.imageProvider = imageProvider
        self.scaleMode = scaleMode
        
        self.device = renderState.device
        self.commandQueue = renderState.commandQueue
        self.ciContext = renderState.ciContext
        self.opaqueBackground = CIImage.black
        super.init()
    }
    
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(), let drawable = view.currentDrawable else { return }
        
        inFlightSemaphore.wait()
        
        commandBuffer.addCompletedHandler { _ -> Void in
            self.inFlightSemaphore.signal()
        }
        
        // Create a displayable image for the current time.
        var image = self.imageProvider(view.scaleFactor)
        let drawableSize = view.drawableSize
        
        //resize the image to fit the dimensions of the drawable layer, based on the scaling mode provided
        image = image.transformed(drawableSize: drawableSize, scaleMode: self.scaleMode)
        
        // Blend the image over an opaque background image.
        // This is needed if the image is smaller than the view, or if it has transparent pixels.
        image = image.composited(over: self.opaqueBackground)
        
        // Create a destination the Core Image context uses to render to the drawable's Metal texture.
        let destination = CIRenderDestination(width: Int(drawableSize.width),
                                              height: Int(drawableSize.height),
                                              pixelFormat: view.colorPixelFormat,
                                              commandBuffer: commandBuffer,
                                              mtlTextureProvider: { () -> MTLTexture in
            // Core Image calls the texture provider block lazily when starting a task to render to the destination.
            return drawable.texture
        })
        
        // Start a task that renders to the texture destination.
        do {
            try self.ciContext.startTask(
                toRender: image,
                from: CGRect(origin: .zero, size: drawableSize),
                to: destination, at: CGPoint.zero
            )
        } catch {
            print(error)
        }
        
        // Insert a command to present the drawable when the buffer has been scheduled for execution.
        commandBuffer.present(drawable)
        
        // Commit the command buffer so that the GPU executes the work that the Core Image Render Task issues.
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Respond to drawable size or orientation changes.
    }
}

extension CoreImageRenderer {
    enum ScaleMode {
        case scaleToFit
        case scaleToFill
    }
}

private extension CoreImageRenderer.ScaleMode {
    func scalingBetween(sizeA: CGSize, sizeB: CGSize) -> CGFloat {
        let widthScale = sizeA.width / sizeB.width
        let heightScale = sizeA.height / sizeB.height
        
        switch self {
        case .scaleToFit:
            return min(widthScale, heightScale)
        case .scaleToFill:
            return max(widthScale, heightScale)
        }
    }
}

extension CIImage {
    func transformed(drawableSize: CGSize, scaleMode: CoreImageRenderer.ScaleMode) -> CIImage {
        var image = self
        let imageSize = self.extent.size
        
        let scale = scaleMode.scalingBetween(sizeA: drawableSize, sizeB: imageSize)
        image = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let xOffset = (drawableSize.width / 2) - ((imageSize.width * scale) / 2)
        let yOffset = (drawableSize.height / 2) - ((imageSize.height * scale) / 2)
        image = image.transformed(by: CGAffineTransform(translationX: xOffset, y: yOffset))
        
        return image
    }
}


