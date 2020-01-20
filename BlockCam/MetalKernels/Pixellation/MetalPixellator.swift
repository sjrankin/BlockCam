//
//  MetalPixellator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import CoreImage
import CoreMedia
import CoreGraphics

class MetalPixellator
{
    /// Initialize the class.
    init()
    {
        ImageDevice = MTLCreateSystemDefaultDevice()
        let Library = ImageDevice?.makeDefaultLibrary()
        let PFunction = Library?.makeFunction(name: "MetalPixellation")
        do
        {
            PPipeline = try MetalDevice?.makeComputePipelineState(function: PFunction!)
        }
        catch
        {
            Log.AbortMessage("Error creating pixellation kernel: \(error.localizedDescription)", FileName: #file, FunctionName: #function)
            {
                Message in
                fatalError(Message)
            }
        }
    }
    
    private var WasInitialized = false
    let MetalDevice = MTLCreateSystemDefaultDevice()
    var PPipeline: MTLComputePipelineState? = nil
    var ImageDevice: MTLDevice? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return MetalDevice?.makeCommandQueue()
    }()
    var ParameterBuffer: MTLBuffer! = nil
    
    /// Pixellate the image using a Metal kernel.
    /// - Parameter Image: The image to reduce by pixellation.
    /// - Returns: Class with edge data. Nil on error.
    public func ReduceImage(_ Image: UIImage, PixelSize: Int) -> [UIColor]?
    {
        let StartTime = CACurrentMediaTime()
        let CgImage = Image.cgImage
        //let ImageColorSpace = CgImage?.colorSpace
        let ImageWidth: Int = (CgImage?.width)!
        let ImageHeight: Int = (CgImage?.height)!
        
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
        
        let Results = [simd_float4](repeating: simd_float4(0.0, 0.0, 0.0, 1.0), count: ImageWidth * ImageHeight)
        let ReducedDataBuffer = MetalDevice!.makeBuffer(bytes: Results, length: MemoryLayout<simd_float4>.stride * ImageWidth * ImageHeight, options: [])
        let ReducedData = UnsafeBufferPointer<simd_float4>(start: UnsafePointer(ReducedDataBuffer!.contents().assumingMemoryBound(to: simd_float4.self)),
                                                           count: ImageWidth * ImageHeight)
        
        let Parameter = PixellateParameters(Width: simd_uint1(PixelSize), Height: simd_uint1(PixelSize))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<PixellateParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<PixellateParameters>.stride)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(PPipeline!)
        CommandEncoder?.setTexture(Texture, index: 0)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        CommandEncoder?.setBuffer(ReducedDataBuffer!, offset: 0, index: 1)
        
        let ThreadGroupCount = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(Texture.width / ThreadGroupCount.width,
                                       Texture.height / ThreadGroupCount.height,
                                       1)
        
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        var PColorTable = [UIColor]()
        for PColor in ReducedData
        {
            let r = PColor[0]
            let g = PColor[1]
            let b = PColor[2]
            let a = 1.0
            PColorTable.append(UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a)))
        }
        let FinishTime = CACurrentMediaTime() - StartTime
        print("Metal pixellation duration: \(FinishTime) seconds")
        return PColorTable
    }
}
