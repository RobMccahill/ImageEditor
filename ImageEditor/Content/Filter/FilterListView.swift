//
//  FilterListView.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 31/01/2025.
//

import SwiftUI
import Combine

struct FilterListView: View {
    @Bindable var stack: FilterStack
    
    var body: some View {
        List {
            Section("Colour Effects") {
                ExposureFilterView(filter: stack.exposureFilter)
                BrightnessFilterView(filter: stack.colorControlFilter)
                ContrastFilterView(filter: stack.colorControlFilter)
                SaturationFilterView(filter: stack.colorControlFilter)
                VibranceFilterView(filter: stack.vibranceFilter)
                SepiaFilterView(filter: stack.sepiaFilter)
            }
            Section("Blur Effects") {
                BlurFilterView(filter: stack.blurFilter)
            }
            
        }.listStyle(.sidebar)
    }
}

#Preview {
    FilterListView(stack: FilterStack())
}
