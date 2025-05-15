//
//  Contrast.metal
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

#include <metal_stdlib>
using namespace metal;

struct contrast_input {
    float contrastFactor;
};

kernel void contrast(texture2d<half, access::read> inTexture [[texture(0)]],
                     texture2d<half, access::write> outTexture [[texture(1)]],
                     constant contrast_input& input [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    half4 inColor = inTexture.read(gid);
    half4 outColor = half4(((inColor.rgb - half3(0.5)) * input.contrastFactor + half3(0.5)), inColor.a);
    outTexture.write(outColor, gid);
}
