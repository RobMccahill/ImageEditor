//
//  Constants.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 30/01/2025.
//

import Foundation
import CoreImage

struct Constants {
    static let sampleImage: CIImage =  {
        let url = Bundle.main.url(forResource: "Beach", withExtension: "png")!
        return CIImage(data: try! Data(contentsOf: url))!
    }()
}
