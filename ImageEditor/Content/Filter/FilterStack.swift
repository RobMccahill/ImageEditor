//
//  FilterStack.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/02/2025.
//

import Foundation
import CoreImage
import SwiftUI

@Observable
class FilterStack {
    let exposureFilter = ExposureFilter()
    let colorControlFilter = ColorControlFilter()
    let vibranceFilter = VibranceFilter()
    let sepiaFilter = SepiaFilter()
    let blurFilter = BlurFilter()
    
    var filters: [ImageFilter] { [
        exposureFilter,
        colorControlFilter,
        vibranceFilter,
        sepiaFilter,
        blurFilter
    ] }
    
    func reset() {
        filters.forEach { $0.reset() }
    }
}
