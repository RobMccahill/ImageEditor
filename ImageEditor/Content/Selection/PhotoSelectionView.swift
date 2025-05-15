//
//  PhotoSelectionView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 30/01/2025.
//

import SwiftUI
import PhotosUI

struct PhotoSelectionView: View {
    @State private var selectedItem: PhotosPickerItem?
    var onPhotoSelected: (CIImage) -> Void = { _ in }
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Select Photo", systemImage: "photo.circle")
                    .imageScale(.large)
                    .padding(4)
                    
            }.buttonStyle(.borderedProminent)
        }
        .onChange(of: selectedItem) {
            Task {
                do {
                    let result = try await selectedItem?.loadTransferable(type: RawImageData.self)
                    guard let imageData = result else { throw RawImageData.TransferError.unknownError }
                    self.onPhotoSelected(imageData.ciImage)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct RawImageData: Transferable {
    let data: Data
    let ciImage: CIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let ciImage = CIImage(data: data) else {
                throw RawImageData.TransferError.unknownError
            }
            
            return RawImageData(data: data, ciImage: ciImage)
        }
    }
}

extension RawImageData {
    enum TransferError: Error {
        case unknownError
    }
}


#Preview {
    PhotoSelectionView()
}
