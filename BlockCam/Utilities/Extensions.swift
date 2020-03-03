//
//  Extensions.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import simd

/// Extensions for Double.
extension Double
{
    /// Clamp the instance value to the supplied range.
    /// - Note: No range checking is done.
    /// - Parameter Low: Low end of the valid range. Defaults to 0.0
    /// - Parameter High: High end of the valid range. Defaults to 1.0
    /// - Returns: The instance value unchanged if it is within the specified range, the range limit value if it is not.
    func Clamp(Low: Double = 0.0, High: Double = 1.0) -> Double
    {
        if self < Low
        {
            return Low
        }
        if self > High
        {
            return High
        }
        return self
    }
}

/// Extension methods for UIImage.
extension UIImage
{
    /// Rotate the instance image to the number of passed radians.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Radians: Number of radians to rotate the image to.
    func Rotate(Radians: CGFloat) -> UIImage
    {
        var NewSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: Radians)).size
        NewSize.width = floor(NewSize.width)
        NewSize.height = floor(NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, self.scale)
        let Context = UIGraphicsGetCurrentContext()
        Context?.translateBy(x: NewSize.width / 2, y: NewSize.height / 2)
        Context?.rotate(by: Radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))
        let Rotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Rotated!
    }
    
    /// Returns the color of the instance image at the passed coordinates.
    /// - Parameter X: Horizontal coordinate.
    /// - Parameter Y: Vertical coordinate.
    /// - Returns: Color at (`X`,`Y`) on success, nil on error.
    subscript (X: Int, Y: Int) -> UIColor?
    {
        if X < 0 || X > Int(size.width) || Y < 0 || Y > Int(size.height)
        {
            return nil
        }
        guard let Provider = self.cgImage!.dataProvider else
        {
            return nil
        }
        let ProviderData = Provider.data
        let ImageData = CFDataGetBytePtr(ProviderData)
        let NumberOfComponents = 4
        let PixelAddress = ((Int(size.width) * Y) + X) * NumberOfComponents
        let R = CGFloat(ImageData![PixelAddress]) / 255.0
        let G = CGFloat(ImageData![PixelAddress + 1]) / 255.0
        let B = CGFloat(ImageData![PixelAddress + 2]) / 255.0
        let A = CGFloat(ImageData![PixelAddress + 3]) / 255.0
        return UIColor(red: R, green: G, blue: B, alpha: A)
    }
}

/// ULR extensions.
/// - Note: See [Get File Size in Swift](https://stackoverflow.com/questions/28268145/get-file-size-in-swift)
extension URL
{
    /// Gets attributes from the object the instance URL points to. If attributes cannot be retrieved, nil is returned.
    var Attributes: [FileAttributeKey: Any]?
    {
        do
        {
            return try FileManager.default.attributesOfItem(atPath: path)
        }
        catch
        {
            Log.Message("FileAttribute error.")
        }
        return nil
    }
    
    /// Returns the size of the object the instance URL points to.
    var FileSize: UInt64
    {
        return Attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    /// Returns the size of the object the instance URL points to, converted to a string in standard iOS format.
    var FileSizeAsString: String
    {
        return ByteCountFormatter.string(fromByteCount: Int64(FileSize), countStyle: .file)
    }
    
    /// Returns the creation date of the object the instance URL points to.
    var CreationDate: Date?
    {
        return Attributes?[.creationDate] as? Date
    }
    
    //https://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift/36012850
    var IsValid: Bool
    {
        let Raw = self.path
        let Detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let Match = Detector.firstMatch(in: Raw, options: [], range: NSRange(location: 0, length: Raw.utf16.count))
        {
            return Match.range.length == Raw.utf16.count
        }
        else
        {
            return false
        }
    }
}

/// Extensions for DispatchQueue.
extension DispatchQueue
{
    /// Run a closure in the background with a possibly delayed completion block.
    /// - Note: `completion` will be called on the UI thread.
    /// - Parameter delay: The amount of time to wait before calling `Completion` on the UI thread.
    /// - Parameter action: The closure to run on the background thread. If nil, nothing is executed.
    /// - Parameter completion: The completion block run after the specified delay and on the UI thread.
    static func Background(delay: Double = 0.0, action: (() -> Void)? = nil,
                           completion: (() -> Void)? = nil)
    {
        DispatchQueue.global(qos: .background).async
            {
                action?()
                if let CompletionBlock = completion
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay,
                                                  execute:
                        {
                            CompletionBlock()
                    }
                    )
                }
        }
    }
}

/// Extensions for UIColor.
extension UIColor
{
    /// Create a UIColor using a hex string generated by `Hex`.
    /// - Note: The format of `HexString` is `#rrggbbaa` where `rr`, `gg`, `bb`, and `aa`
    ///         are all hexidecimal values. Badly formatted strings will result in nil
    ///         being returned.
    /// - Parameter HexString: The string to use as the source value for the color.
    /// - Returns: Nil on error, UIColor on success.
    convenience init?(HexString: String)
    {
        if let (Red, Green, Blue, Alpha) = Utilities.ColorChannelsFrom(HexString)
        {
            self.init(red: Red, green: Green, blue: Blue, alpha: Alpha)
        }
        else
        {
            return nil
        }
    }
    
    /// Returns the value of the color as a hex string. The string has the prefix
    /// `#` and is in RGBA order.
    var Hex: String
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let IRed = Int(Red * 255.0)
            let SRed = String(format: "%02x", IRed)
            let IGreen = Int(Green * 255.0)
            let SGreen = String(format: "%02x", IGreen)
            let IBlue = Int(Blue * 255.0)
            let SBlue = String(format: "%02x", IBlue)
            let IAlpha = Int(Alpha * 255.0)
            let SAlpha = String(format: "%02x", IAlpha)
            let Final = "#" + SRed + SGreen + SBlue + SAlpha
            return Final
        }
    }
    
    /// Returns the YUV equivalent of the instance color, in Y, U, V order.
    /// - See
    ///   - [YUV](https://en.wikipedia.org/wiki/YUV)
    ///   - [FourCC YUV to RGB Conversion](http://www.fourcc.org/fccyvrgb.php)
    var YUV: (Y: CGFloat, U: CGFloat, V: CGFloat)
    {
        get
        {
            let Wr: CGFloat = 0.299
            let Wg: CGFloat = 0.587
            let Wb: CGFloat = 0.114
            let Umax: CGFloat = 0.436
            let Vmax: CGFloat = 0.615
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Y = (Wr * Red) + (Wg * Green) + (Wb * Blue)
            let U = Umax * ((Blue - Y) / (1.0 - Wb))
            let V = Vmax * ((Red - Y) / (1.0 - Wr))
            return (Y, U, V)
        }
    }
    
    /// Returns the CMYK equivalent of the instance color, in C, M, Y, K order.
    var CMYK: (C: CGFloat, Y: CGFloat, M: CGFloat, K: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let K: CGFloat = 1.0 - max(Red, max(Green, Blue))
            var C: CGFloat = 0.0
            var M: CGFloat = 0.0
            var Y: CGFloat = 0.0
            if K == 1.0
            {
                C = 1.0
            }
            else
            {
                C = abs((1.0 - Red - K) / (1.0 - K))
            }
            if K == 1.0
            {
                M = 1.0
            }
            else
            {
                M = abs((1.0 - Green - K) / (1.0 - K))
            }
            if K == 1.0
            {
                Y = 1.0
            }
            else
            {
                Y = abs((1.0 - Blue - K) / (1.0 - K))
            }
            return (C, M, Y, K)
        }
    }
    
    /// Returns the CIE LAB equivalent of the instance color, in L, A, B order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var LAB: (L: CGFloat, A: CGFloat, B: CGFloat)
    {
        get
        {
            let (X, Y, Z) = self.XYZ
            var Xr = X / 111.144                //X referent is X10 incandescent/tungsten
            var Yr = Y / 100.0                  //Y referent is X10 incandescent/tungsten
            var Zr = Z / 35.2                   //Z referent is X10 incandescent/tungsten
            if Xr > 0.008856
            {
                Xr = pow(Xr, (1.0 / 3.0))
            }
            else
            {
                Xr = (7.787 * Xr) + (16.0 / 116.0)
            }
            if Yr > 0.008856
            {
                Yr = pow(Yr, (1.0 / 3.0))
            }
            else
            {
                Yr = (7.787 * Yr) + (16.0 / 116.0)
            }
            if Zr > 0.008856
            {
                Zr = pow(Zr, (1.0 / 3.0))
            }
            else
            {
                Zr = (7.787 * Zr) + (16.0 / 116.0)
            }
            let L = (Xr * 116.0) - 16.0
            let A = 500.0 * (Xr - Yr)
            let B = 200.0 * (Yr - Zr)
            return (L, A, B)
        }
    }
    
    /// Returns the XYZ equivalent of the instance color, in X, Y, Z order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var XYZ: (X: CGFloat, Y: CGFloat, Z: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            if Red > 0.04045
            {
                Red = pow(((Red + 0.055) / 1.055), 2.4)
            }
            else
            {
                Red = Red / 12.92
            }
            if Green > 0.04045
            {
                Green = pow(((Green + 0.055) / 1.055), 2.4)
            }
            else
            {
                Green = Green / 12.92
            }
            if Blue > 0.04045
            {
                Blue = pow(((Blue + 0.055) / 1.055), 2.4)
            }
            else
            {
                Blue = Blue / 12.92
            }
            Red = Red * 100.0
            Green = Green * 100.0
            Blue = Blue * 100.0
            let X = (Red * 0.4124) + (Green * 0.3576) * (Blue * 0.1805)
            let Y = (Red * 0.2126) + (Green * 0.7152) * (Blue * 0.0722)
            let Z = (Red * 0.0193) + (Green * 0.1192) * (Blue * 0.9505)
            return (X, Y, Z)
        }
    }
    
    /// Returns the HSL equivalent of the instance color, in H, S, L order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var HSL: (H: CGFloat, S: CGFloat, L: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Min = min(Red, Green, Blue)
            let Max = max(Red, Green, Blue)
            let Delta = Max - Min
            let L: CGFloat = (Max + Min) / 2.0
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            if Delta != 0.0
            {
                if L < 0.5
                {
                    S = Max / (Max + Min)
                }
                else
                {
                    S = Max / (2.0 - Max - Min)
                }
                let DeltaR = (((Max - Red) / 6.0) + (Max / 2.0)) / Max
                let DeltaG = (((Max - Green) / 6.0) + (Max / 2.0)) / Max
                let DeltaB = (((Max - Blue) / 6.0) + (Max / 2.0)) / Max
                if Red == Max
                {
                    H = DeltaB - DeltaG
                }
                else
                    if Green == Max
                    {
                        H = (1.0 / 3.0) + (DeltaR - DeltaB)
                    }
                    else
                        if Blue == Max
                        {
                            H = (2.0 / 3.0) + (DeltaG - DeltaR)
                }
                if H < 0.0
                {
                    H = H + 1.0
                }
                if H > 1.0
                {
                    H = H - 1.0
                }
            }
            return (H, S, L)
        }
    }
    
    /// Returns the greatest channel magnitude.
    var GreatestMagnitude: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return max(Red, Green, Blue)
        }
    }
    
    /// Returns the least channel magnitude.
    var LeastMagnitude: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return min(Red, Green, Blue)
        }
    }
    
    /// Convert an instance of a UIColor to a SIMD float4 structure.
    /// - Returns: SIMD float4 equivalent of the instance color.
    func ToFloat4() -> simd_float4
    {
        var FVals = [Float]()
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 1.0
        self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        FVals.append(Float(Red))
        FVals.append(Float(Green))
        FVals.append(Float(Blue))
        FVals.append(Float(Alpha))
        let Result = simd_float4(FVals)
        return Result
    }
    
    /// Returns a brightened version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's brightness component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Brightened color.
    func Brighten(By Percent: CGFloat) -> UIColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = 1.0 + Percent
        Brightness = Brightness * Multiplier
        return UIColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
    
    /// Returns a darkened version of the instance color.
    /// - Paraemter By: The percent value to multiply the instance color's brightness component by.
    ///                 If this is not a normal value (0.0 - 1.0), the original color is returned
    ///                 unchanged.
    /// - Returns: Darkened color.
    func Darken(By Percent: CGFloat) -> UIColor
    {
        if Percent >= 1.0
        {
            return self
        }
        if Percent < 0.0
        {
            return self
        }
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        let Multiplier = Percent
        Brightness = Brightness * Multiplier
        return UIColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
    }
}

/// Extensions for Character.
extension Character
{
    /// Returns the data for a png image of the character.
    /// - Parameter ofSize: The size of the font to use.
    /// - Returns: Pointer to the png's data on success, nil on error.
    func png(ofSize FontSize: CGFloat) -> Data?
    {
        let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize)]
        let CharStr = "\(self)" as NSString
        let Size = CharStr.size(withAttributes: attribute)
        UIGraphicsBeginImageContext(Size)
        CharStr.draw(at: CGPoint(x: 0, y: 0), withAttributes: attribute)
        var Png: Data? = nil
        if let CharImage = UIGraphicsGetImageFromCurrentImageContext()
        {
            Png = CharImage.pngData()
        }
        UIGraphicsEndImageContext()
        return Png
    }
    
    /// Size of a font character.
    private static let UnicodeSize: CGFloat = 8
    /// Holds a unicode png image for the no glyph available glyph.
    private static let UnicodePng = Character("\u{1fff}").png(ofSize: UnicodeSize)
    
    /// Determines if the instance character is available in the current font.
    /// - Note: This is done by comparing png data for the unavailable glyph glyph against the glyph for the
    ///         instance character.
    /// - Returns: True if the glyph is available in the font, false if not.
    func IsAvailable() -> Bool
    {
        if let UnicodePng = Character.UnicodePng,
            let MyPng = self.png(ofSize: Character.UnicodeSize)
        {
            return UnicodePng != MyPng
        }
        return false
    }
}

/// Convenience extensions for UUID.
extension UUID
{
    /// Returns an empty UUID (all zero values for all fields).
    public static var Empty: UUID
    {
        get
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
    }
}

/// String extensions.
extension String
{
    /// Determines if the string consists of all of the same character.
    /// - Parameter Same: Character to compare against the contents of the instance string. If the passed value is
    ///                   empty or has more than one character, false is returned.
    /// - Returns: True if the instance string contains only the `Same` character, false otherwise.
    public func IsAll(_ Same: String) -> Bool
    {
        if Same.count != 1
        {
            return false
        }
        for Char in self
        {
            if String(Char) != Same
            {
                return false
            }
        }
        return true
    }
    
    /// Returns a string with `Count` of the same characters.
    /// - Parameter Value: The character to repeat
    public static func Repeating(_ Value: String, Count: Int) -> String
    {
        if Count < 1
        {
            return ""
        }
        if Value.count != 1
        {
            return ""
        }
        var ReturnMe = ""
        for _ in 0 ..< Count
        {
            ReturnMe.append(Value)
        }
        return ReturnMe
    }
}

/// Extensions for CIImage.
extension CIImage
{
    /// Convert the instance `CIImage` to a `UIImage`.
    /// - Returns: `UIImage` equivalent of the instance `CIImage` Nil return on error.
    func AsUIImage() -> UIImage?
    {
        let Context: CIContext = CIContext(options: nil)
        if let CGImg: CGImage = Context.createCGImage(self, from: self.extent)
        {
        let Final: UIImage = UIImage(cgImage: CGImg)
        return Final
        }
        return nil
    }
}

/// UIView extensions.
extension UIView
{
    /// Return the instance `UIView`'s parent view controller. Nil returned if not found.
    /// - Notes: See [Given a view, how do I get its ViewController?](https://stackoverflow.com/questions/1372977/given-a-view-how-do-i-get-its-viewcontroller)
    var ParentViewController: UIViewController?
    {
        var ParentResponder: UIResponder? = self
        while ParentResponder != nil
        {
            ParentResponder = ParentResponder!.next
            if let VC = ParentResponder as? UIViewController
            {
                return VC
            }
        }
        return nil
    }
    
    func ToImage() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let SomeView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return SomeView!
    }
}

/// NSCharacterSet extension to return all characters in a font.
extension NSCharacterSet
{
    /// Returns all characters in the instance character set.
    /// - Note: See [Get all available characters from a font.](https://stackoverflow.com/questions/41592139/get-all-available-characters-from-a-font)
    var Characters: [String]
    {
        var Chars = [String]()
        for Plane: UInt8 in 0 ... 16
        {
            if self.hasMemberInPlane(Plane)
            {
                let P0 = UInt32(Plane) << 16
                let P1 = (UInt32(Plane) + 1) << 16
                for c: UTF32Char in P0 ..< P1
                {
                    if self.longCharacterIsMember(c)
                    {
                        var C1 = c.littleEndian
                        let S = NSString(bytes: &C1, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)!
                        Chars.append(String(S))
                    }
                }
            }
        }
        return Chars
    }
}
