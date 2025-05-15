//
//  MethodSelectionView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 30/01/2025.
//

import SwiftUI

struct MethodSelectionView: View {
    @State private var image: CIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Welcome")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding(24)
                    Spacer()
                }
                VStack {
                    VStack(spacing: 24) {
                        PhotoSelectionView(onPhotoSelected: { image in
                            self.image = image
                        })
                        FileSelectionView { image in
                            self.image = image
                        }
                    }.navigationDestination(item: $image) { image in
                        ImageEditorView(image: image)
                            .navigationTitle("Edit Image")
                    }
                }
            }
        }.navigationTitle("Select Image")
    }
}


#Preview {
    MethodSelectionView()
}
