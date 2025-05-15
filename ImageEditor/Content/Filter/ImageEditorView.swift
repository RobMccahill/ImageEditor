//
//  MetalFilterView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 28/01/2025.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

struct ImageEditorView: View {
    @State private var modifiedImage: CIImage
    @State private var showSaveFileSheet = false
    @State private var showFileExporter = false
    @State private var imageToSave: ImageDocument?
    @State private var exportMethod: ImageExporter?
    @State private var filterStack: FilterStack
    @State private var resourceProvider: MetalResourceProvider
    
    let image: CIImage
    
    init(image: CIImage) {
        let stack = FilterStack()
        self.filterStack = stack
        self.image = image
        self.modifiedImage = image
        self.resourceProvider = MetalResourceProvider(image: image, filterStack: stack)
    }
    
    var body: some View {
        HStack {
            FilterListView(stack: filterStack)
                .frame(maxWidth: 200)
                .listStyle(.sidebar)
            VStack {
                MetalView(renderer: MetalRenderer(resourceProvider: resourceProvider))
                HStack(spacing: 16) {
                    Button("Reset Image") {
                        self.filterStack.reset()
                    }
                    Button {
                        self.modifiedImage = resourceProvider.render()!
                        self.showSaveFileSheet = true
                    } label: {
                        Text("Save Image")
                    }
                    .sheet(
                        isPresented: $showSaveFileSheet) {
                            SaveImageView(selectedExportMethod: self.$exportMethod, shouldShow: $showSaveFileSheet, exportMethodSelected: self.$showFileExporter)
                        }
                        .fileExporter(
                            isPresented: $showFileExporter,
                            document: ImageDocument(image: self.modifiedImage, exporter: self.exportMethod), contentType: self.exportMethod?.imageContentType ?? .png, onCompletion: { result in
                                print("Success")
                            }
                        )
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}


#Preview {
    ImageEditorView(image: Constants.sampleImage)
        .padding()
}
