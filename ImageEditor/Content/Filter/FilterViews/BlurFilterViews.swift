//
//  BlurFilterViews.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/02/2025.
//

import Foundation
import CoreImage
import SwiftUI
import Combine

@Observable
class BlurFilter: ImageFilter {
    let name = "Blur"
    var radius: Float = 0
    
    func reset() {
        radius = 0.0
    }
}

struct BlurFilterView: View {
    @Bindable var filter: BlurFilter
    
    var body: some View {
        VStack {
            HStack {
                Text("Blur").font(.title3)
                Spacer()
            }
            CustomSlider(value: $filter.radius, range: 0...25)
        }
    }
}
