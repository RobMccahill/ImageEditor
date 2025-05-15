//
//  ImageDocument.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 05/02/2025.
//
import SwiftUI
import CoreImage
import UniformTypeIdentifiers

fileprivate let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.jpeg, .png, .tiff, .heif, .exr] }
    var image: CIImage
    var exporter: ImageExporter
    
    init(image: CIImage?, exporter: ImageExporter? = nil) {
        self.image = image ?? CIImage()
        self.exporter = exporter ?? PngExporter()
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = CIImage(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.image = image
        self.exporter = PngExporter()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try exporter.representation(for: image)
        guard let data = data else { throw CocoaError(.fileWriteUnknown) }
        return FileWrapper(regularFileWithContents: data)
    }
}

protocol ImageExporter {
    var imageContentType: UTType { get }
    func representation(for image: CIImage) throws -> Data?
}

struct PngExporter: ImageExporter {
    let imageContentType: UTType = .png
    
    func representation(for image: CIImage) throws -> Data? {
        let context = CIContext()
        return context.pngRepresentation(of: image, format: context.workingFormat, colorSpace: image.colorSpace ?? sRGB)
    }
}

struct JpegExporter: ImageExporter {
    let imageContentType: UTType = .jpeg
    
    func representation(for image: CIImage) throws -> Data? {
        let context = CIContext()
        return context.jpegRepresentation(of: image, colorSpace: image.colorSpace ?? sRGB)
    }
}

struct HeifExporter: ImageExporter {
    let imageContentType: UTType = .heif
    
    func representation(for image: CIImage) throws -> Data? {
        let context = CIContext()
        return context.heifRepresentation(of: image, format: context.workingFormat, colorSpace: image.colorSpace ?? sRGB)
    }
}

struct TiffExporter: ImageExporter {
    let imageContentType: UTType = .tiff
    
    func representation(for image: CIImage) throws -> Data? {
        let context = CIContext()
        return context.tiffRepresentation(of: image, format: context.workingFormat, colorSpace: image.colorSpace ?? sRGB)
    }
}

struct OpenEXRExporter: ImageExporter {
    let imageContentType: UTType = .exr
    
    func representation(for image: CIImage) throws -> Data? {
        let context = CIContext()
        return try context.openEXRRepresentation(of: image)
    }
}
