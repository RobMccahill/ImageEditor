//
//  CustomSlider.swift
//  ImageEditor
//
//  Created by Robert Mccahill on 02/04/2025.
//

import Foundation
import SwiftUI

//Based off the example provided from: https://priva28.medium.com/making-a-custom-slider-in-swiftui-db440cd6d88c

struct CustomSlider: View {
    @Binding var value: Float
    private var translatedValue: CGFloat { CGFloat(self.value).map(from: self.range, to: self.sliderRange) }
    
    @State private var sliderWidth: CGFloat = 50
    @State private var highlightedWidth: CGFloat = 0
    
    var range: ClosedRange<CGFloat>
    
    var sliderRange: ClosedRange<CGFloat> {
        return self.leadingOffset...(self.sliderWidth - self.knobSize.width - self.trailingOffset)
    }
    
    var leadingOffset: CGFloat = 0
    var trailingOffset: CGFloat = 0
    
    var knobSize: CGSize = CGSize(width: 20, height: 20)
    
    var trackGradient = LinearGradient(gradient: Gradient(colors: [Color(.sliderGrey)]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(self.trackGradient)
                .frame(height: 4)
            HStack {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: translatedValue, height: 4)
                Spacer()
            }
            HStack {
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: self.knobSize.width, height: self.knobSize.height)
                    .foregroundColor(.gray)
                    .offset(x: translatedValue)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                self.highlightedWidth = highlightedWidth(for: gesture.location)
                                self.value = Float(self.value(for: gesture.location))
                            }
                    )
                Spacer()
            }
        }
        .onGeometryChange(for: CGSize.self, of: \.size) { size in
            self.sliderWidth = size.width
            self.highlightedWidth = CGFloat(translatedValue)
        }
        .contentShape(RoundedRectangle(cornerRadius: 50))
        .gesture(SpatialTapGesture().onEnded({ gesture in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.highlightedWidth = highlightedWidth(for: gesture.location)
                self.value = Float(self.value(for: gesture.location))
            }
        }))
    }
    
    func highlightedWidth(for location: CGPoint) -> CGFloat {
        let trailingEdge = self.sliderWidth - self.knobSize.width - self.trailingOffset
        let translatedPosition = location.x - (self.knobSize.width / 2)
        return translatedPosition.clamped(to: self.leadingOffset...trailingEdge)
    }
    
    func value(for location: CGPoint) -> CGFloat {
        let trailingEdge = self.sliderWidth - self.knobSize.width - self.trailingOffset
        let translatedPosition = location.x - (self.knobSize.width / 2)
        let sliderPosition = translatedPosition.clamped(to: self.leadingOffset...trailingEdge)
        
        return sliderPosition.map(from: self.sliderRange, to: self.range)
    }
}

private extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.max(range.lowerBound, Swift.min(self, range.upperBound))
    }
}


#Preview {
    @Previewable @State var value: Float = 5.0
    CustomSlider(value: $value, range: 0...100)
}
