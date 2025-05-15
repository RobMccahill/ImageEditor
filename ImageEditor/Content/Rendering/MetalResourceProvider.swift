//
//  MetalResourceProvider.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

import CoreImage
import Metal
import MetalKit
import MetalPerformanceShaders

class MetalResourceProvider {
    private let image: CIImage
    private let renderState: RenderState
    private var initialTexture: MTLTexture?
    private var intermediateTexture: MTLTexture?
    private var drawableViewSize: CGSize?
    
    let library: MTLLibrary
    let shaderPipeline: ShaderPipeline
    let filterStack: FilterStack
    let metalFilterStack: MetalFilterStack
    
    init(image: CIImage, filterStack: FilterStack, renderState: RenderState = .shared) {
        self.image = image
        self.renderState = renderState
        self.library = renderState.device.makeDefaultLibrary()!
        self.filterStack = filterStack
        self.metalFilterStack = MetalFilterStack()
        self.shaderPipeline = ShaderPipeline(
            device: renderState.device,
            library: self.library,
            shaders: [
                self.metalFilterStack.saturationFilter,
                self.metalFilterStack.exposureFilter,
                self.metalFilterStack.brightnessFilter,
                self.metalFilterStack.contrastFilter
            ]
        )
    }
    
    func getInitialTexture() -> MTLTexture {
        if let texture = initialTexture {
            return texture
        } else {
            let textureProvider = MTKTextureLoader(device: renderState.device)
            let cgImage = renderState.ciContext.createCGImage(image, from: image.extent)
            //TODO: Check shared storage mode as this might not work for devices with non-unified memory
            let texture = try! textureProvider.newTexture(cgImage: cgImage!, options: [.textureStorageMode : MTLStorageMode.shared.rawValue])
            self.initialTexture = texture
            return texture
        }
    }
    
    func getIntermediateTexture(forView view: MTKView) -> MTLTexture {
        if let texture = intermediateTexture, drawableViewSize == view.drawableSize {
            return texture
        } else {
            let texture = makeTexture(size: view.drawableSize, colorPixelFormat: view.colorPixelFormat)
            self.intermediateTexture = texture
            self.drawableViewSize = view.drawableSize
            
            return texture
        }
    }
    
    func applyShaderPipeline(to destinationTexture: MTLTexture, commandBuffer: MTLCommandBuffer, scaleToSize drawableSize: CGSize? = nil) {
        let initialTexture = getInitialTexture()
        var destinationTexture = destinationTexture
        
        if let drawableSize = drawableSize {
            let scale = MPSImageBilinearScale(device: renderState.device)
            let imageSize = CGSize(width: Double(initialTexture.width), height: Double(initialTexture.height))
            let scaling = Double(scalingBetween(sizeA: drawableSize, sizeB: imageSize))
            let xOffset = (drawableSize.width / 2) - ((imageSize.width * scaling) / 2)
            let yOffset = (drawableSize.height / 2) - ((imageSize.height * scaling) / 2)
            
            var transform = MPSScaleTransform(scaleX: scaling, scaleY: scaling, translateX: xOffset, translateY: yOffset)
            
            withUnsafePointer(to: &transform) { transformPointer -> () in
                scale.scaleTransform = transformPointer
                scale.encode(commandBuffer: commandBuffer, sourceTexture: initialTexture, destinationTexture: destinationTexture)
            }
        } else {
            let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
            blitEncoder.copy(from: initialTexture, to: destinationTexture)
            blitEncoder.endEncoding()
        }
        
        metalFilterStack.update(from: filterStack)
        shaderPipeline.apply(to: destinationTexture, buffer: commandBuffer)
        
        let blur = MPSImageGaussianBlur(device: renderState.device, sigma: filterStack.blurFilter.radius)
        blur.encode(commandBuffer: commandBuffer, inPlaceTexture: &destinationTexture)
    }
    
    func render() -> CIImage? {
        guard let commandBuffer = renderState.commandQueue.makeCommandBuffer() else {
            return nil
        }
        
        let initialTexture = getInitialTexture()
        //Using rgba8Unorm pixel format for the output texture here for file export reasons - CIContext seems to use the format present in the texture, but also relies on it being in rgba8Unorm format compared to the metal default of bgra8Unorm. Might need to revisit this when looking at EDR/HDR content and test on other devices
        let outputTexture = makeTexture(size: CGSize(width: initialTexture.width, height: initialTexture.height), colorPixelFormat: .rgba8Unorm)
        
        applyShaderPipeline(to: outputTexture, commandBuffer: commandBuffer)
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        let options: [CIImageOption : Any] = [
            .colorSpace: colorSpace
        ]
        
        let ciImage = CIImage(mtlTexture: outputTexture, options: options)!
        return ciImage.oriented(.downMirrored)
    }
    
    private func makeTexture(size: CGSize, colorPixelFormat: MTLPixelFormat) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: colorPixelFormat,
            width: Int(size.width),
            height: Int(size.height),
            mipmapped: false
        )
        
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        textureDescriptor.storageMode = .shared
        let texture = renderState.device.makeTexture(descriptor: textureDescriptor)!
        
        return texture
    }
    
    private func scalingBetween(sizeA: CGSize, sizeB: CGSize) -> CGFloat {
        let widthScale = sizeA.width / sizeB.width
        let heightScale = sizeA.height / sizeB.height
        return min(widthScale, heightScale)
    }
}
