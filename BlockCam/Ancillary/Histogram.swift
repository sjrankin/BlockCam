//
//  Histogram.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Accelerate.vImage

class Histogram
{
    init()
    {
        
    }
    
    init(_ Image: UIImage)
    {
        Generate(Image)
    }
    
    func Generate(_ Image: UIImage, Buckets: Int = 256) -> UIImage?
    {
        Results.removeAll()
        if let CGImg = Image.cgImage
        {
        let Source = CIImage(cgImage: CGImg)
            let HistoFilter = CIFilter(name: "CIAreaHistogram")
            HistoFilter?.setValue(Source, forKey: kCIInputImageKey)
            let Extent = CIVector(cgRect: CGRect(x: 0, y: 0, width: CGImg.width, height: CGImg.height))
            HistoFilter?.setValue(Extent, forKey: kCIInputExtentKey)
            HistoFilter?.setValue(Buckets, forKey: "inputCount")
            HistoFilter?.setValue(50.0, forKey: kCIInputScaleKey)
            if let OneD = HistoFilter?.outputImage
            {
                let HistoImage = CIFilter(name: "CIHistogramDisplayFilter")
                HistoImage?.setValue(OneD, forKey: kCIInputImageKey)
                HistoImage?.setValue(100, forKey: "inputHeight")
                if let Result = HistoImage?.outputImage
                {
                    return UIImage(ciImage: Result)
                }
            }
        }
        return nil
    }
    
    func GenerateXX(_ Image: UIImage, Buckets: Int = 256)
    {
        Results.removeAll()
        if let ImageRef = Image.cgImage
        {
            if let InProvider = ImageRef.dataProvider
            {
                let Format = vImage_CGImageFormat(
                    bitsPerComponent: 8,
                    bitsPerPixel: 32,
                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                    renderingIntent: .defaultIntent)!
                //let InBitmap = InProvider.data
                guard var InBuffer = try? vImage_Buffer(cgImage: ImageRef, format: Format) else
                {
                    Log.Message("Error loading vImageBuffer.")
                    return
                }
                let Alpha = [UInt](repeating: 0, count: Buckets)
                let Red = [UInt](repeating: 0, count: Buckets)
                let Green = [UInt](repeating: 0, count: Buckets)
                let Blue = [UInt](repeating: 0, count: Buckets)
                let AlphaPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Alpha) as UnsafeMutablePointer<vImagePixelCount>?
                let RedPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Red) as UnsafeMutablePointer<vImagePixelCount>?
                let GreenPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Green) as UnsafeMutablePointer<vImagePixelCount>?
                let BluePtr = UnsafeMutablePointer<vImagePixelCount>(mutating: Blue) as UnsafeMutablePointer<vImagePixelCount>?
                let RGBA = [RedPtr, GreenPtr, BluePtr, AlphaPtr]
                let HistRawData = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>?>(mutating: RGBA)
                let VError = vImageHistogramCalculation_ARGB8888(&InBuffer, HistRawData, UInt32(kvImageNoFlags))
                guard VError == kvImageNoError else
                {
                    Log.Message("Error calculating histogram.")
                    return
                }
                for Index in 0 ..< Buckets
                {
                    let FinalRed: CGFloat = CGFloat(Red[Index]) / 255.0
                    let FinalGreen: CGFloat = CGFloat(Green[Index]) / 255.0
                    let FinalBlue: CGFloat = CGFloat(Blue[Index]) / 255.0
                    Results.append((Red: FinalRed, Green: FinalGreen, Blue: FinalBlue))
                }
            }
        }
    }
    
    func MaxRed() -> CGFloat
    {
        var Max: CGFloat = -1.0
        for (Red, _, _) in Results
        {
            if Red > Max
            {
                Max = Red
            }
        }
        return Max
    }
    
    func MaxGreen() -> CGFloat
    {
        var Max: CGFloat = -1.0
        for (_, Green, _) in Results
        {
            if Green > Max
            {
                Max = Green
            }
        }
        return Max
    }
    
    func MaxBlue() -> CGFloat
    {
        var Max: CGFloat = -1.0
        for (_, _, Blue) in Results
        {
            if Blue > Max
            {
                Max = Blue
            }
        }
        return Max
    }
    
    func GenerateX(_ Image: UIImage, Buckets: Int = 256)
    {
        Results.removeAll()
        let Format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
            renderingIntent: .defaultIntent)!
        guard let Source = Image.cgImage,
            var SourceBuffer = try? vImage_Buffer(cgImage: Source, format: Format) else
        {
            Log.Message("Error converting source image.")
            return
        }
        defer { SourceBuffer.free() }
        let HistogramBuckets = (0...3).map
        {
            _ in
            return [vImagePixelCount](repeating: 0, count: Buckets)
        }
        var VError = kvImageNoError
        var MutableHistogram: [UnsafeMutablePointer<vImagePixelCount>?] = HistogramBuckets.map
        {
            return UnsafeMutablePointer<vImagePixelCount>(mutating: $0)
        }
        VError = vImageHistogramCalculation_ARGB8888(&SourceBuffer, &MutableHistogram, vImage_Flags(kvImageNoFlags))
        guard VError == kvImageNoError else
        {
            Log.Message("Error calculating histogram.")
            return
        }
    }
    
    var Results: [(Red: CGFloat, Green: CGFloat, Blue: CGFloat)] = []
}
