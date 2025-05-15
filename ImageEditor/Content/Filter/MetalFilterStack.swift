//
//  MetalFilterStack.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

class MetalFilterStack {
    let saturationFilter = SaturationImageShader()
    let exposureFilter = ExposureImageShader()
    let brightnessFilter = BrightnessImageShader()
    let contrastFilter = ContrastImageShader()
    
    func update(from filterStack: FilterStack) {
        self.saturationFilter.input = SaturationInput(saturationFactor: filterStack.colorControlFilter.saturation)
        self.exposureFilter.input = ExposureInput(exposureFactor: filterStack.exposureFilter.intensity)
        self.brightnessFilter.input = BrightnessInput(brightnessFactor: filterStack.colorControlFilter.brightness)
        self.contrastFilter.input  = ContrastInput(contrastFactor: filterStack.colorControlFilter.contrast)
    }
}
