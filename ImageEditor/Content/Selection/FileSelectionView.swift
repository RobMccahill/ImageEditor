//
//  FileSelectionView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 30/01/2025.
//

import SwiftUI

struct FileSelectionView: View {
    @State private var showFileImporter = false
    var onImageSelected: (CIImage) -> Void = { _ -> Void in }

    var body: some View {
        Button {
            showFileImporter = true
        } label: {
            Label("Import File", systemImage: "doc.circle")
                .imageScale(.large)
                .padding(4)
        }
        .buttonStyle(.borderedProminent)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                guard let file = files.first else {
                    return
                }
                
                let accessGranted = file.startAccessingSecurityScopedResource()
                
                if accessGranted, let data = try? Data(contentsOf: file), let image = CIImage(data: data) {
                    onImageSelected(image)
                } else {
                    print("Error selecting file")
                }
                
                file.stopAccessingSecurityScopedResource()
            case .failure(let error):
                // handle error
                print(error)
            }
        }
    }
}

#Preview {
    FileSelectionView()
}
