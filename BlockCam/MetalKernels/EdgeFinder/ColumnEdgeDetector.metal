//
//  ColumnEdgeDetector.metal
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

/// Look at a given column (defined by `gid`) for pixel colors. If a pixel color is not `Scan.NotColor`, mark the location.
/// - Note: If `gid.y` is not 0, control is returned immediately. Otherwise, the entire column is read and the first non-
///         `Scan.NotColor` pixel is saved when scanning top-to-bottom and bottom-to-top.
/// - Parameter InTexture: The image to scan.
/// - Parameter Scan: Contains the color that is essentially the image's background color.
/// - Parameter TopSide: Array that will contain the results for the top side once all of the columns have been tested.
/// - Parameter BottomSide: Array that will contain the results for the bottom side once all of the columns have been tested.
/// - Parameter gid: Thread position in the grid (essentially the X,Y coordinates of the pixel).
kernel void ColumnEdgeDetector(texture2d<float, access::read> InTexture[[texture(0)]],
                               device ScanningParameters &Scan [[buffer(0)]],
                               device int *TopSide [[buffer(1)]],
                               device int *BottomSide [[buffer(2)]],
                               uint2 gid [[thread_position_in_grid]])
{
    if (gid.y > 0)
        {
        return;
        }
    uint TopMost = InTexture.get_height();
    for (uint Y = 0; Y < InTexture.get_height(); Y++)
        {
        float4 Pixel = InTexture.read(gid.x, Y);
        if (Pixel.r != Scan.NotColor.r || Pixel.g != Scan.NotColor.g || Pixel.b != Scan.NotColor.b)
            {
            TopMost = Y;
            break;
            }
        }
    uint BottomMost = 0;
    for (uint Y = InTexture.get_height() - 1; Y != 0; Y--)
        {
        float4 Pixel = InTexture.read(gid.x, Y);
        if (Pixel.r != Scan.NotColor.r || Pixel.g != Scan.NotColor.g || Pixel.b != Scan.NotColor.b)
            {
            BottomMost = Y;
            break;
            }
        }
    
    TopSide[gid.x] = TopMost;
    BottomSide[gid.x] = BottomMost;
}

