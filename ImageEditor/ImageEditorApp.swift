//
//  ImageEditorApp.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 28/01/2025.
//

import SwiftUI

@main
struct ImageEditorApp: App {
    var body: some Scene {
        WindowGroup {
            MethodSelectionView()
                .safeAreaPadding()
        }.defaultSize(width: 600, height: 400)
    }
}
