//
//  ImageEdgeFinder.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import CoreImage
import CoreMedia
import CoreGraphics

/// Finds the first pixel one each edge of an image that is not a pre-determined color.
class ImageEdgeFinder
{
    /// Initialize the class.
    init()
    {
        ImageDevice = MTLCreateSystemDefaultDevice()
        let Library = ImageDevice?.makeDefaultLibrary()
        let RowFunction = Library?.makeFunction(name: "ScanLineEdgeDetector")
        let ColumnFunction = Library?.makeFunction(name: "ColumnEdgeDetector")
        do
        {
            RowPipeline = try MetalDevice?.makeComputePipelineState(function: RowFunction!)
        }
        catch
        {
            Log.AbortMessage("Error creating scanline edge finder kernel: \(error.localizedDescription)", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
        do
        {
            ColumnPipeline = try MetalDevice?.makeComputePipelineState(function: ColumnFunction!)
        }
        catch
        {
            Log.AbortMessage("Error creating column edge finder kernel: \(error.localizedDescription)", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
    }
    
    private var WasInitialized = false
     let MetalDevice = MTLCreateSystemDefaultDevice()
     var RowPipeline: MTLComputePipelineState? = nil
     var ColumnPipeline: MTLComputePipelineState? = nil
     var ImageDevice: MTLDevice? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return MetalDevice?.makeCommandQueue()
    }()
     var ParameterBuffer: MTLBuffer! = nil
    
    /// Find the first non-`NotInColor` pixel on each side of the passed image.
    /// - Note: The values returned are for the first pixel that is *not* the background color.
    /// - Parameter Image: The image to find the first non-`NotInColor` pixel.
    /// - Parameter NotInColor: Color that is essentially the background color of the image. This determines the edge returned.
    /// - Returns: Class with edge data. Nil on error.
    public func FindEdgesIn(_ Image: UIImage, NotInColor: UIColor) -> ImageEdges?
    {
        let StartTime = CACurrentMediaTime()
        let CgImage = Image.cgImage
        //let ImageColorSpace = CgImage?.colorSpace
        let ImageWidth: Int = (CgImage?.width)!
        let ImageHeight: Int = (CgImage?.height)!
        let LeftResults = [Int](repeating: ImageWidth - 1, count: ImageHeight)
        let RightResults = [Int](repeating: 0, count: ImageHeight)
        let TopResults = [Int](repeating: ImageHeight - 1, count: ImageWidth)
        let BottomResults = [Int](repeating: 0, count: ImageWidth)
        
        var RawData = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight))
        let RGBColorSpace = CGColorSpaceCreateDeviceRGB()
        let BitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let Context = CGContext(data: &RawData, width: ImageWidth, height: ImageHeight, bitsPerComponent: (CgImage?.bitsPerComponent)!,
                                bytesPerRow: (CgImage?.bytesPerRow)!, space: RGBColorSpace, bitmapInfo: BitmapInfo.rawValue)!
        Context.draw(CgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(ImageWidth), height: CGFloat(ImageHeight)))
        let TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: Int(ImageWidth), height: Int(ImageHeight),
                                                                         mipmapped: true)
        guard let Texture = ImageDevice?.makeTexture(descriptor: TextureDescriptor) else
        {
            Log.AbortMessage("Error creating input texture.", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
            return nil
        }
        
        let Region = MTLRegionMake2D(0, 0, Int(ImageWidth), Int(ImageHeight))
        Texture.replace(region: Region, mipmapLevel: 0, withBytes: &RawData, bytesPerRow: Int((CgImage?.bytesPerRow)!))
        
        let ColumnTopResultsBuffer = MetalDevice!.makeBuffer(bytes: TopResults, length: MemoryLayout<simd_int1>.stride * ImageWidth, options: [])
        let ColumnTopData = UnsafeBufferPointer<simd_int1>(start: UnsafePointer(ColumnTopResultsBuffer!.contents().assumingMemoryBound(to: simd_int1.self)),
                                                           count: ImageWidth)
        let ColumnBottomResultsBuffer = MetalDevice!.makeBuffer(bytes: BottomResults, length: MemoryLayout<simd_int1>.stride * ImageWidth, options: [])
        let ColumnBottomData = UnsafeBufferPointer<simd_int1>(start: UnsafePointer(ColumnBottomResultsBuffer!.contents().assumingMemoryBound(to: simd_int1.self)),
                                                              count: ImageWidth)
        
        var Parameter = ScanningParameters(NotColor: NotInColor.ToFloat4())
        var Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ScanningParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ScanningParameters>.stride)
        
        let ColumnCommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let ColumnCommandEncoder = ColumnCommandBuffer?.makeComputeCommandEncoder()
        
        ColumnCommandEncoder?.setComputePipelineState(ColumnPipeline!)
        ColumnCommandEncoder?.setTexture(Texture, index: 0)
        ColumnCommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        ColumnCommandEncoder?.setBuffer(ColumnTopResultsBuffer!, offset: 0, index: 1)
        ColumnCommandEncoder?.setBuffer(ColumnBottomResultsBuffer!, offset: 0, index: 2)
        
        var ThreadGroupCount = MTLSizeMake(8, 8, 1)
        var ThreadGroups = MTLSizeMake(Texture.width / ThreadGroupCount.width,
                                       Texture.height / ThreadGroupCount.height,
                                       1)
        
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        
        ColumnCommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        ColumnCommandEncoder?.endEncoding()
        ColumnCommandBuffer?.commit()
        ColumnCommandBuffer?.waitUntilCompleted()
        
        var Small = Int.max
        for ColumnTop in ColumnTopData
        {
            if ColumnTop < Small
            {
                Small = Int(ColumnTop)
            }
        }
        print("Top-most pixel=\(Small)")
        var Big = 0
        for ColumnBottom in ColumnBottomData
        {
            if ColumnBottom > Big
            {
                Big = Int(ColumnBottom)
            }
        }
        print("Bottom-most pixel=\(Big)")
        
        let RowLeftResultsBuffer = MetalDevice!.makeBuffer(bytes: LeftResults, length: MemoryLayout<simd_int1>.stride * ImageWidth, options: [])
        let RowLeftData = UnsafeBufferPointer<simd_int1>(start: UnsafePointer(RowLeftResultsBuffer!.contents().assumingMemoryBound(to: simd_int1.self)),
                                                           count: ImageWidth)
        let RowRightResultsBuffer = MetalDevice!.makeBuffer(bytes: RightResults, length: MemoryLayout<simd_int1>.stride * ImageWidth, options: [])
        let RowRightData = UnsafeBufferPointer<simd_int1>(start: UnsafePointer(RowRightResultsBuffer!.contents().assumingMemoryBound(to: simd_int1.self)),
                                                              count: ImageWidth)
        
         Parameter = ScanningParameters(NotColor: NotInColor.ToFloat4())
         Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ScanningParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<ScanningParameters>.stride)
        
        let RowCommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let RowCommandEncoder = RowCommandBuffer?.makeComputeCommandEncoder()
        
        RowCommandEncoder?.setComputePipelineState(RowPipeline!)
        RowCommandEncoder?.setTexture(Texture, index: 0)
        RowCommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        RowCommandEncoder?.setBuffer(RowLeftResultsBuffer!, offset: 0, index: 1)
        RowCommandEncoder?.setBuffer(RowRightResultsBuffer!, offset: 0, index: 2)
        
         ThreadGroupCount = MTLSizeMake(8, 8, 1)
         ThreadGroups = MTLSizeMake(Texture.width / ThreadGroupCount.width,
                                       Texture.height / ThreadGroupCount.height,
                                       1)
        
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        
        RowCommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        RowCommandEncoder?.endEncoding()
        RowCommandBuffer?.commit()
        RowCommandBuffer?.waitUntilCompleted()
        
        var Left = Int.max
        for RowLeft in RowLeftData
        {
            if RowLeft < Left
            {
                Left = Int(RowLeft)
            }
        }
        print("Left-most pixel=\(Small)")
        var Right = 0
        for RowRight in RowRightData
        {
            if RowRight > Right
            {
                Right = Int(RowRight)
            }
        }
        print("Right-most pixel=\(Right)")
        
        let Duration = CACurrentMediaTime() - StartTime
        print("Edge duration: \(Duration)")
        return nil
    }
}

/// Holds image edges found in `EdgeFinder.FindEdgesIn` function. Each value is the location of the first
/// pixel that *is not the background color*.
class ImageEdges
{
    /// The top-most non-background color pixel.
    var TopEdge: Int = Int.max
    /// The left-most non-background color pixel.
    var LeftEdge: Int = Int.max
    /// The bottom-most non-background color pixel.
    var BottomEdge: Int = 0
    /// the right-most non-background color pixel.
    var RightEdge: Int = 0
}
