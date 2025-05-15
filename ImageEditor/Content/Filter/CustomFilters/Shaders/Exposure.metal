//
//  Exposure.metal
//  ImageEditor
//
//  Created by Robert Mccahill on 01/04/2025.
//

#include <metal_stdlib>
using namespace metal;

struct exposure_input {
    float exposureFactor;
};

kernel void exposure(texture2d<half, access::read> inTexture [[texture(0)]],
                     texture2d<half, access::write> outTexture [[texture(1)]],
                     constant exposure_input& input [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    half4 inColor = inTexture.read(gid);
    half4 outColor = half4(inColor.rgb * pow(2.0, input.exposureFactor), 1.0);
    outTexture.write(outColor, gid);
}
