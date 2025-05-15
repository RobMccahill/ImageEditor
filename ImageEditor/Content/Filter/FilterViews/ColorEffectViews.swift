//
//  ColorEffectViews.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/02/2025.
//

import Foundation
import CoreImage
import SwiftUI

@Observable
class SepiaFilter: ImageFilter {
    let name = "Sepia"
    var intensity: Float = 0.0
    
    func reset() {
        intensity = 0.0
    }
}

struct SepiaFilterView: View {
    @Bindable var filter: SepiaFilter
    
    var body: some View {
        VStack {
            HStack {
                Text(filter.name).font(.title3)
                Spacer()
            }
            HStack {
                CustomSlider(
                    value: $filter.intensity,
                    range: 0...1
                )
            }
            
        }
    }
}
