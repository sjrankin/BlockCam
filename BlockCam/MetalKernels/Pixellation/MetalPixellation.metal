//
//  MetalPixellation.metal
//  BlockCam
//
//  Created by Stuart Rankin on 1/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//  Code from Core Image for Swift by Simon J. Gladman.
//

#include <metal_stdlib>
using namespace metal;

struct PixellateParameters
{
    uint Width;
    uint Height;
};

kernel void MetalPixellation(texture2d<float, access::read> InTexture [[texture(0)]],
                             device PixellateParameters &Dimensions [[buffer(0)]],
                             device float4 *Results [[buffer(1)]],
                             uint2 gid [[thread_position_in_grid]])
{
    uint Width = Dimensions.Width;
    uint Height = Dimensions.Height;
    uint2 Location = uint2((gid.x / Width) * Width, (gid.y / Height) * Height);
    float4 Color = InTexture.read(Location);
    uint Index = (gid.x * Width) + gid.y;
    Results[Index] = Color;
}
