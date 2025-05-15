//
//  Saturation.metal
//  ImageEditor
//
//  Created by Robert Mccahill on 27/03/2025.
//

#include <metal_stdlib>
using namespace metal;

struct saturate_input {
    float saturationFactor;
};

kernel void saturation(texture2d<half, access::read> inTexture [[texture(0)]],
                       texture2d<half, access::write> outTexture [[texture(1)]],
                       constant saturate_input& input [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    half4 inColor = inTexture.read(gid);
    half value = dot(inColor.rgb, half3(0.2125, 0.7154, 0.0721));
    half4 grayColor(value, value, value, 1.0);
    half4 outColor = mix(grayColor, inColor, input.saturationFactor);
    outTexture.write(outColor, gid);
}
