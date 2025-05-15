//
//  ColorFilters.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/02/2025.
//
import Foundation
import CoreImage
import SwiftUI

@Observable
class ExposureFilter: ImageFilter {
    let name = "Exposure"
    var intensity: Float = 0.0
    
    func reset() {
        intensity = 0.0
    }
}

struct ExposureFilterView: View {
    @Bindable var filter: ExposureFilter
    
    var body: some View {
        VStack {
            HStack {
                Text(filter.name).font(.title3)
                Spacer()
            }
            HStack {
                CustomSlider(
                    value: $filter.intensity,
                    range: -1...1
                )
            }
            
        }
    }
}

@Observable
class ColorControlFilter: ImageFilter {
    let name = "Color Control"
    let brightnessName = "Brightness"
    let contrastName = "Contrast"
    let saturationName = "Saturation"
    
    var brightness: Float = 0.0
    var contrast: Float = 1.0
    var saturation: Float = 1.0
    
    func reset() {
        brightness = 0.0
        contrast = 1.0
        saturation = 1.0
    }
}

struct BrightnessFilterView: View {
    @Bindable var filter: ColorControlFilter
    
    var body: some View {
        VStack {
            HStack {
                Text(filter.brightnessName).font(.title3)
                Spacer()
            }
            HStack {
                CustomSlider(
                    value: $filter.brightness,
                    range: -0.5...0.5
                )
            }
            
        }
    }
}

struct ContrastFilterView: View {
    @Bindable var filter: ColorControlFilter
    
    var body: some View {
        VStack {
            HStack {
                Text(filter.contrastName).font(.title3)
                Spacer()
            }
            HStack {
                CustomSlider(
                    value: $filter.contrast,
                    range: 0.5...1.5
                )
            }
            
        }
    }
}

struct SaturationFilterView: View {
    @Bindable var filter: ColorControlFilter
    
    var body: some View {
        VStack {
            HStack {
                Text(filter.saturationName).font(.title3)
                Spacer()
            }
            HStack {
                CustomSlider(
                    value: $filter.saturation,
                    range: 0.0...2.0
                )
            }
            
        }
    }
}

@Observable
class VibranceFilter: ImageFilter {
    let name = "Vibrance"
    var intensity: Float = 0.0
    
    func reset() {
        intensity = 0.0
    }
}

struct VibranceFilterView: View {
    @Bindable var filter: VibranceFilter
    
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
