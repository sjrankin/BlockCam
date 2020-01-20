//
//  ScanLineEdgeDetector.metal
//  BlockCam
//
//  Created by Stuart Rankin on 1/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ScanningParameters
{
    float4 NotColor;
};


/// Look at a given scan line (defined by `gid`) for pixel colors. If a pixel color is not `Scan.NotColor`, mark the location.
/// - Note: If `gid.x` is not 0, control is returned immediately. Otherwise, the entire scanline is read and the first non-
///         `Scan.NotColor` pixel is saved when scanning left-to-right and right-to-left.
/// - Parameter InTexture: The image to scan.
/// - Parameter Scan: Contains the color that is essentially the image's background color.
/// - Parameter LeftSide: Array that will contain the results for the left side once all of the scanlines have been tested.
/// - Parameter RightSide: Array that will contain the results for the right side once all of the scanlines have been tested.
/// - Parameter gid: Thread position in the grid (essentially the X,Y coordinates of the pixel).
kernel void ScanLineEdgeDetector(texture2d<float, access::read> InTexture[[texture(0)]],
                               device ScanningParameters &Scan [[buffer(0)]],
                               device int *LeftSide [[buffer(1)]],
                               device int *RightSide [[buffer(2)]],
                               uint2 gid [[thread_position_in_grid]])
{
    if (gid.x > 0)
        {
        return;
        }
    uint LeftMost = InTexture.get_width();
    for (uint X = 0; X < InTexture.get_width(); X++)
        {
        float4 Pixel = InTexture.read(X, gid.y);
        if (Pixel.r != Scan.NotColor.r || Pixel.g != Scan.NotColor.g || Pixel.b != Scan.NotColor.b)
            {
            LeftMost = X;
            break;
            }
        }
    uint RightMost = 0;
    for (uint X = InTexture.get_width() - 1; X != 0; X--)
        {
        float4 Pixel = InTexture.read(X, gid.y);
        if (Pixel.r != Scan.NotColor.r || Pixel.g != Scan.NotColor.g || Pixel.b != Scan.NotColor.b)
            {
            RightMost = X;
            break;
            }
        }
    LeftSide[gid.y] = LeftMost;
    RightSide[gid.y] = RightMost;
}

