//
//  SaveImageView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 17/03/2025.
//

import SwiftUI

struct SaveImageView: View {
    @Binding var selectedExportMethod: ImageExporter?
    @Binding var shouldShow: Bool
    @Binding var exportMethodSelected: Bool
    @State private var selectedType: ExportType = .png
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Export Type")
            Picker("", selection: $selectedType) {
                Text("PNG").tag(ExportType.png)
                Text("JPEG").tag(ExportType.jpeg)
                Text("HEIC").tag(ExportType.heif)
                Text("TIFF").tag(ExportType.tiff)
                Text("OpenEXR").tag(ExportType.openEXR)
            }
            .pickerStyle(.segmented)
            
            HStack {
                Spacer()
                Button("Cancel") {
                    shouldShow = false
                }
                
                Button("Save") {
                    switch selectedType {
                    case .png:
                        selectedExportMethod = PngExporter()
                    case .jpeg:
                        selectedExportMethod = JpegExporter()
                    case .heif:
                        selectedExportMethod = HeifExporter()
                    case .tiff:
                        selectedExportMethod = TiffExporter()
                    case .openEXR:
                        selectedExportMethod = OpenEXRExporter()
                    }
                    
                    shouldShow = false
                    exportMethodSelected = true
                }.buttonStyle(.borderedProminent)
            }.padding(.top, 8)
        }.safeAreaPadding(8)
    }
    
    private enum ExportType: Hashable {
        case png, jpeg, heif, tiff, openEXR
    }
}

#Preview {
    SaveImageView(selectedExportMethod: .constant(nil), shouldShow: .constant(false), exportMethodSelected: .constant(false))
}
