//
//  Utilities.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/15/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Utilities
{
    /// Pad the passed string with specified leading characters to make the string no longer
    /// than `ForCount` characters in length.
    /// - Parameter Value: The value to pre-pad.
    /// - Parameter WithLeading: The string (assumed to be one character long) to use to pad
    ///                          the beginning of `Value`.
    /// - Parameter ForCount: The final total length of the returned string. If `Value` is already
    ///                       this length or greater, it is returned unchanged.
    /// - Returns: Padded string.
    public static func Pad(_ Value: String, _ WithLeading: String, _ ForCount: Int) -> String
    {
        if Value.count >= ForCount
        {
            return Value
        }
        let Delta = ForCount - Value.count
        let Many = String(repeating: WithLeading, count: Delta)
        return Many + Value
    }
    
    /// Pad the passed string with specified leading characters to make the string no longer
    /// than `ForCount` characters in length.
    /// - Parameter Value: The value to pre-pad. Passed as an integer.
    /// - Parameter WithLeading: The string (assumed to be one character long) to use to pad
    ///                          the beginning of `Value`.
    /// - Parameter ForCount: The final total length of the returned string. If `Value` is already
    ///                       this length or greater, it is returned unchanged.
    /// - Returns: Padded string.
    public static func Pad(_ Value: Int, _ WithLeading: String, _ ForCount: Int) -> String
    {
        return Pad("\(Value)", WithLeading, ForCount)
    }
    
    /// Pad the passed string with specified trailing characters to make the string no longer
    /// than `ForCount` characters in length.
    /// - Parameter Value: The value to post-pad.
    /// - Parameter WithLeading: The string (assumed to be one character long) to use to pad
    ///                          the ending of `Value`.
    /// - Parameter ForCount: The final total length of the returned string. If `Value` is already
    ///                       this length or greater, it is returned unchanged.
    /// - Returns: Padded string.
    public static func Pad(_ Value: String, WithTrailing: String, ForCount: Int) -> String
    {
        if Value.count >= ForCount
        {
            return Value
        }
        let Delta = ForCount - Value.count
        let Many = String(repeating: WithTrailing, count: Delta)
        return Value + Many
    }
    
    /// Returns a sequential integer. The integer is stored in the user settings and will reset (loop around to the start) once
    /// the value passes .LoopSequentialIntegerAfter and be set to the value in .StartSequentialIntegerAt.
    public static func GetNextSequentialInteger() -> Int
    {
        var SeqInt = Settings.GetInteger(ForKey: .NextSequentialInteger)
        if SeqInt > Settings.GetInteger(ForKey: .LoopSequentialIntegerAfter)
        {
            SeqInt = Settings.GetInteger(ForKey: .StartSequentialIntegerAt)
        }
        Settings.SetInteger(SeqInt + 1, ForKey: .NextSequentialInteger)
        return SeqInt
    }
    
    /// Creates a sequential name. This is a name with a string prefix, a sequenced number, and an extension, such as
    /// `Image0066.jpg`
    /// - Parameter Prefix: The prefix of the name. If not supplied, "Sequence" will be used instead.
    /// - Parameter Extension: The extension of the file. No periods should be supplied.
    /// - Returns: File name as described above.
    public static func MakeSequentialName(_ Prefix: String, Extension: String) -> String
    {
        let FilePrefix = Prefix.isEmpty ? "Sequence" : Prefix
        let Sequence = GetNextSequentialInteger()
        let SeqStr = Pad(Sequence, "0", 4)
        let Name = FilePrefix + SeqStr + "." + Extension
        return Name
    }
    
    /// Creates a sequential name using the supplied value.
    /// - Parameter Prefix: The previs of the name. If not supplied, "Sequence" will be used.
    /// - Parameter Extension: The extension of the file. No periods should be supplied.
    /// - Parameter Sequence: The sequnce value to use. Incremented by 1 here.
    /// - Returns: File name as described above.
    public static func MakeSequentialName(_ Prefix: String, Extension: String, Sequence: inout Int) -> String
    {
        let FilePrefix = Prefix.isEmpty ? "Squence" : Prefix
        let SequenceString = Pad(Sequence, "0", 5)
        Sequence = Sequence + 1
        let Name = FilePrefix + SequenceString + "." + Extension
        return Name
    }
    
    /// Make a list of color string values as a string.
    /// - Parameter From: Array of color values to convert to a string list. Color values are converted to hex.
    /// - Parameter Separator: Color value separator. Defaults to `,`.
    /// - Parameter AppendNewLine: Determines if a new line character is appended. Defaults to true.
    /// - Returns: String list of color values.
    public static func MakeStringList(From: [UIColor], Separator: String = ",", AppendNewLine: Bool = true) -> String
    {
        var Line = ""
        for Index in 0 ..< From.count
        {
            var Color = From[Index].Hex
            if Index < From.count - 1
            {
                Color = Color + Separator + " "
            }
            Line.append(Color)
        }
        if AppendNewLine
        {
            Line = Line + "\n"
        }
        return Line
    }
    
    /// Make a table (or list of lists) of color values as a string.
    /// - Parameter From: The array of arrays of `UIColor` values. Each color is stored as a hex string.
    /// - Parameter Separator: The color value separator. Defaults to `,`.
    /// - Returns: String of the array of arrays of colors.
    public static func MakeStringArray(From: [[UIColor]], Separator: String = ",") -> String
    {
        var Lines = ""
        for List in From
        {
            Lines.append(MakeStringList(From: List, Separator: Separator))
        }
        return Lines
    }
    
    /// Convert a sring array of colors in to an array of colors.
    /// - Warning: If an invalid color is found, a fatal error is generator.
    /// - Parameter From: The raw string to convert.
    /// - Parameter Separator: Color value separator. Defaults to ','.
    /// - Returns: Array of colors.
    public static func MakeColorArray(From: String, Separator: String = ",") -> [[UIColor]]
    {
        var Results = [[UIColor]]()
        if From.isEmpty
        {
            return Results
        }
        let Lines = From.split(separator: "\n", omittingEmptySubsequences: true)
        for Line in Lines
        {
            let RawLine = String(Line)
            let Colors = RawLine.split(separator: String.Element(Separator), omittingEmptySubsequences: true)
            var LineData = [UIColor]()
            for Color in Colors
            {
                if let FinalColor = UIColor(HexString: String(Color))
                {
                    LineData.append(FinalColor)
                }
                else
                {
                    Log.AbortMessage("Invalid color found in raw color array: \(String(Color))")
                    {
                        Message in
                        fatalError(Message)
                    }
                }
            }
            Results.append(LineData)
        }
        return Results
    }
    
    /// Converts the passed date into a string.
    /// - Parameter ConvertMe: Date to convert.
    /// - Returns: String equivalent of `ConvertMe`.
    public static func DateToString(_ ConvertMe: Date) -> String
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: ConvertMe)
        let Minute = Cal.component(.minute, from: ConvertMe)
        let Second = Cal.component(.second, from: ConvertMe)
        let Year = Cal.component(.year, from: ConvertMe)
        let Month = Cal.component(.month, from: ConvertMe)
        let Day = Cal.component(.day, from: ConvertMe)
        return "\(Year)-\(Pad(Month, "0", 2))-\(Pad(Day, "0", 2)) \(Pad(Hour, "0", 2)):\(Pad(Minute, "0", 2)):\(Pad(Second, "0", 2))"
    }
    
    /// Converts a string date (serialized with `DateToString`) into a `Date` object.
    /// - Parameter ConvertMe: String to convert into a date.
    /// - Returns: `Date` equivalent of the passed string on success, nil on parse failure.
    public static func StringToDate(_ ConvertMe: String) -> Date?
    {
        if ConvertMe.isEmpty
        {
            return nil
        }
        let Parts = ConvertMe.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return nil
        }
        let DatePart = String(Parts[0])
        let TimePart = String(Parts[1])
        let DateParts = DatePart.split(separator: "-", omittingEmptySubsequences: true)
        if DateParts.count != 3
        {
            return nil
        }
        var Year = 0
        var Month = 0
        var Day = 0
        if let temp = Int(String(DateParts[0]))
        {
            Year = temp
        }
        if let temp = Int(String(DateParts[1]))
        {
            Month = temp
        }
        if let temp = Int(String(DateParts[2]))
        {
            Day = temp
        }
        let TimeParts = TimePart.split(separator: ":", omittingEmptySubsequences: true)
        if TimeParts.count != 3
        {
            return nil
        }
        var Hour = 0
        var Minute = 0
        var Second = 0
        if let temp = Int(String(TimeParts[0]))
        {
            Hour = temp
        }
        if let temp = Int(String(TimeParts[1]))
        {
            Minute = temp
        }
        if let temp = Int(String(TimeParts[2]))
        {
            Second = temp
        }
        var Comp = DateComponents()
        Comp.year = Year
        Comp.month = Month
        Comp.day = Day
        Comp.hour = Hour
        Comp.minute = Minute
        Comp.second = Second
        let Cal = Calendar.current
        let FinalDate = Cal.date(from: Comp)
        return FinalDate
    }
    
    /// Create a string representation of the passed double with the supplied precision. No rounding
    /// takes place here (despite the name of the function) - only truncation of the string occurs.
    /// - Parameter Value: The value to be converted to a string then truncated.
    /// - Parameter Precision: The number of fractional digits.
    /// - Returns: Truncated string value based on `Value`.
    public static func RoundedString(Value: Double, Precision: Int = 3) -> String
    {
        let stemp = "\(Value)"
        let Parts = stemp.split(separator: ".", omittingEmptySubsequences: true)
        if Parts.count == 1
        {
            return stemp
        }
        if Parts.count != 2
        {
            fatalError("Too many parts!")
        }
        var Least = String(Parts[1])
        Least = String(Least.prefix(Precision))
        return String(Parts[0]) + "." + Least
    }
    
    /// Table of escaped XML characters. each entry is a tuple with the string to escape, and its associated
    /// escaped value.
    /// - Note: The tuple for `&` *must* be the last entry in order for `FromXMLSafeString` to function correctly.
    public static let XMLTable =
        [
            ("\"", "&quot;"),
            ("'", "&apos;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("&", "&amp;")
    ]
    
    /// Convert a string into an XML-safe string by making necessary escaping character substitutions.
    /// - Note: If `Source` consists of more than one line, it is returned as a CDATA block.
    /// - Parameter Source: The string to convert.
    /// - Returns: Escaped (as necessary) string.
    public static func ToXMLSafeString(_ Source: String) -> String
    {
        var ReturnMe = Source
        if ReturnMe.contains("\n")
        {
            return WrapInCData(ReturnMe)
        }
        for (SourceChar, Escaped) in XMLTable
        {
            ReturnMe = ReturnMe.replacingOccurrences(of: SourceChar, with: Escaped)
        }
        return ReturnMe
    }
    
    /// Convert a potentially escaped XML string into a non-escaped string.
    /// - Parameter Source: The string to convert.
    /// - Returns: Non-escaped string.
    public static func FromXMLSafeString(_ Source: String) -> String
    {
        var ReturnMe = Source
        for (SourceChar, Escaped) in XMLTable
        {
            ReturnMe = ReturnMe.replacingOccurrences(of: Escaped, with: SourceChar)
        }
        return ReturnMe
    }
    
    /// Wrap the passed string in an XML CDATA block.
    /// - Parameter Source: The string to wrap in a CDATA block.
    /// - Returns: Passed string wrapped in a CDATA block.
    public static func WrapInCData(_ Source: String) -> String
    {
        var ReturnMe = "<![CDATA[\n"
        ReturnMe.append(Source)
        ReturnMe.append("\n")
        ReturnMe.append("]]>")
        return ReturnMe
    }
    
    /// Convert a string to a JSON-safe string by changing all new line character to "`\\n`".
    /// - Parameter Source: String to change if necessary to ensure JSON safety.
    /// - Returns: Potentially modified string. If the string has only one line, no changes are made.
    public static func ToJSONSafeString(_ Source: String) -> String
    {
        if !Source.contains("\n")
        {
            return Source
        }
        return Source.replacingOccurrences(of: "\n", with: "\\n")
    }
    
    /// Given a font name in Unix format, return its name and weight.
    /// - Parameter Raw: The raw font name.
    /// - Returns: Tuple with the name and weight (as a string).
    public static func GetFontAndWeight(_ Raw: String) -> (Name: String, Weight: String)?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.split(separator: "-", omittingEmptySubsequences: true)
        if Parts.count == 0
        {
            return nil
        }
        if Parts.count == 1
        {
            return (Name: String(Parts[0]), Weight: "Regular")
        }
        if Parts.count == 2
        {
            return (Name: String(Parts[0]), Weight: String(Parts[1]))
        }
        return nil
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into a `UIColor`. Color order is: rrggbbaa or rrggbb.
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Tuple of color channel information.
    public static func ColorChannelsFrom(_ RawString: String) -> (Red: CGFloat, Green: CGFloat, Blue: CGFloat, Alpha: CGFloat)?
    {
        var Working = RawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if Working.isEmpty
        {
            return nil
        }
        if Working.uppercased().starts(with: "0X")
        {
            Working = Working.replacingOccurrences(of: "0x", with: "")
            Working = Working.replacingOccurrences(of: "0X", with: "")
        }
        if Working.starts(with: "#")
        {
            Working = Working.replacingOccurrences(of: "#", with: "")
        }
        switch Working.count
        {
            case 8:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff000000) >> 24) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff0000) >> 16) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff00) >> 8) / 255.0
                    let Alpha: CGFloat = CGFloat((Value & 0x000000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: Alpha)
            }
            
            case 6:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff0000) >> 16) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff00) >> 8) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: 1.0)
            }
            
            default:
                break
        }
        return nil
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into a `UIColor`. Color order is: rrggbbaa or rrggbb.
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Color represented by the raw string on success, nil on parse failure.
    public static func ColorFrom(_ RawString: String) -> UIColor?
    {
        if let (Red, Green, Blue, Alpha) = ColorChannelsFrom(RawString)
        {
            return UIColor(red: Red, green: Green, blue: Blue, alpha: Alpha)
        }
        return nil
    }
    
    /// Determines if any element in `AnyOf` is in the passed array.
    /// - Parameters:
    ///   - In: The array to check against the passed potential sub-set.
    ///   - AnyOf: The list of data to compare against the contents of `ArrayContains`.
    /// - Returns: True if any element in `AnyOf` is in `InArrayData`, false if not.
    public static func ArrayContains<T>(AnyOf: [T], In ArrayData: [T]) -> Bool where T: Comparable & Hashable
    {
        #if true
        let MainSet = Set<T>(ArrayData)
        return MainSet.union(AnyOf).count > 0
        #else
        for SomeData in ArrayData
        {
            if AnyOf.contains(SomeData)
            {
                return true
            }
        }
        return false
        #endif
    }
    
    /// Remove all items in `RemoveMe` from the passed array.
    /// - Parameter RemoveMe: The list of items to remove from the passed array.
    /// - Parameter From: The array whose items that are in union with `RemoveMe` will be removed.
    /// - Returns: New array without any item in `RemoveMe` as a member.
    public static func RemoveAllOf<T>(_ RemoveMe: [T], From: [T]) -> [T] where T: Comparable
    {
        let Removed = From.filter{!From.contains($0)}
        return Removed
    }
    
    /// Determines if the source set contains the passed subset. All members of `SubSet` must be present.
    /// - Parameter SourceSet: The source set to be tested.
    /// - Parameter SubSet: The subset to test against `SourceSet`.
    /// - Returns: True if all members of `SubSet` are present in `SourceSet`, false if not.
    public static func ContainsSet<T>(_ SourceSet: [T], SubSet: [T]) -> Bool where T: Comparable & Hashable
    {
        let MainSet = Set<T>(SourceSet)
        let Union = MainSet.union(SubSet)
        return Union.count == SubSet.count
    }
    
    public static func ClosestColorFromBorder(_ InImage: UIImage, ThatIsNot: UIColor) -> (Top: Int, Bottom: Int, Left: Int, Right: Int)
    {
        let Context = CIContext(options: nil)
        var LeftMost = Int.max
        var RightMost = 0
        var TopMost = Int.max
        var BottomMost = 0
        let CGImg = InImage.cgImage
        let CIImg = CIImage(cgImage: CGImg!)
        if let BCImage = Context.createCGImage(CIImg, from: CIImg.extent)
        {
            let BytesPerRow: Int = BCImage.bytesPerRow
            let BitsPerPixel: Int = BCImage.bitsPerPixel
            let BitsPerComponent: Int = BCImage.bitsPerComponent
            let PixelData = BCImage.dataProvider!.data
            let Data: UnsafePointer<UInt8> = CFDataGetBytePtr(PixelData)
            let Width: Int = Int(CIImg.extent.width)
            let Height: Int = Int(CIImg.extent.height)
            let ColorSize = BitsPerPixel / BitsPerComponent
            
            for Row in 0 ... Height - 1
            {
                let RowOffset = ((Height - 1) - Row) * BytesPerRow
                for Column in 0 ... Width - 1
                {
                    let Address: Int = RowOffset + (Column * ColorSize)
                    let R = Data[Address + 0]
                    let G = Data[Address + 1]
                    let B = Data[Address + 2]
                    let A = Data[Address + 3]
                    let PixelColor = UIColor(red: CGFloat(R) / 255.0, green: CGFloat(G) / 255.0, blue: CGFloat(B) / 255.0, alpha: CGFloat(A) / 255.0)
                    if PixelColor != ThatIsNot
                    {
                        if Column < LeftMost
                        {
                            LeftMost = Column
                        }
                    }
                }
            }
        }
    
        return (TopMost, BottomMost, LeftMost, RightMost)
    }
    
    /// Crop the passed image such that the returned image has no more than `Borders` pixels between the last non-background
    /// color and the edge of the image.
    /// - Note:
    ///     - If the image in either dimension is less than `Borders` * 2, the image will be returned unaltered.
    ///     - If cropping is disabled, the original image is returned unaltered.
    /// - Parameter Image: The image to crop.
    /// - Parameter Borders: The size of the border.
    public static func CropImage(_ Image: UIImage, Borders: Int) -> UIImage
    {
        #if true
        return Image
        #else
        let ImageSize = Image.size
        if Int(ImageSize.width) < Borders * 2
        {
            return Image
        }
        if Int(ImageSize.height) < Borders * 2
        {
            return Image
        }
        
        let BGColor = UIColor(HexString: Settings.GetString(ForKey: .SceneBackgroundColor)!)!
        let (Top, Bottom, Left, Right) = ClosestColorFromBorder(Image, ThatIsNot: BGColor)
        print("CropImage: Top=\(Top), Left=\(Left), Bottom=\(Bottom), Right=\(Right)")
        
        return Image
        #endif
    }
    
    /// Returns a random character from the passed font.
    /// - Parameter FontName: The name of the font from which the character set will be generated from which a random
    ///                       character will be returned. The same font name will use cached data.
    /// - Parameter FontSize: The size of the font.
    /// - Returns: Random character in the font constructed from the passed font name and size.
    public static func RandomCharacterFromFont(_ FontName: String, _ FontSize: CGFloat) -> String
    {
        let Start = CACurrentMediaTime()
        RandomCharacterCalls = RandomCharacterCalls + 1
        if let Cache = CharSetCache[FontName]
        {
            let CachedChars = Cache.Characters
            let End = CACurrentMediaTime() - Start
            RandomCharacterDurations = RandomCharacterDurations + End
            return CachedChars.randomElement()!
        }
        let Font = UIFont(name: FontName, size: FontSize)
        let Descriptor = Font!.fontDescriptor
        let CharSet: NSCharacterSet = Descriptor.object(forKey: UIFontDescriptor.AttributeName.characterSet) as! NSCharacterSet
        CharSetCache[FontName] = CharSet
        let End = CACurrentMediaTime() - Start
        RandomCharacterDurations = RandomCharacterDurations + End
        return CharSet.Characters.randomElement()!
    }
    
    private static var RandomCharacterCalls = 0
    private static var RandomCharacterDurations: Double = 0
    
    public static func GetMeanRandomCharacterDurations() -> Double
    {
        if RandomCharacterCalls == 0
        {
            RandomCharacterDurations = 0.0
            return 0.0
        }
        let Mean = RandomCharacterDurations / Double(RandomCharacterCalls)
        RandomCharacterCalls = 0
        RandomCharacterDurations = 0.0
        return Mean
    }
    
    /// Holds a cache of character sets.
    public static var CharSetCache: [String: NSCharacterSet] = [String: NSCharacterSet]()
    
    /// Returns a list of randomly selected fonts. No font is repeated.
    /// - Parameter Count: The number of randomly selected fonts to return.
    /// - Returns: List of randomly selected font names (PostScript).
    public static func RandomlySelectedFontList(_ Count: Int) -> [String]
    {
        var FontList = Set<String>()
        while FontList.count < Count
        {
            FontList.insert(GetRandomFont())
        }
        return Array(FontList)
    }
    
    /// Returns a random PostScript font name.
    /// - Returns: PostScript font name.
    public static func GetRandomFont() -> String
    {
        let FontList = MakeFontList()
        let RandomFamily = FontList.randomElement()
        let RandomPSName = RandomFamily?.PSNames.randomElement()
        return RandomPSName!
    }
    
    /// Type returned by `MakeFontList`.
    typealias FontData = (Family: String, Weights: [String], PSNames: [String])
    
    /// Returns a list of fonts the app can read.
    /// - Note: The fonts are scanned only once rather than at each call.
    /// - Returns: List of sorted (by font name) fonts. Each element in the returned array is a tuple
    ///            with the font family, weights, and PostScript names. See `FontData` type alias.
    public static func MakeFontList() -> [FontData]
    {
        if FontList != nil
        {
            return FontList!
        }
        FontList = [FontData]()
        for Family in UIFont.familyNames
        {
            var Weights = Set<String>()
            let Names = UIFont.fontNames(forFamilyName: Family)
            var LLNames = [String]()
            for Name in Names
            {
                if let Font = UIFont(name: Name, size: 12.0)
                {
                    let FDesc = Font.fontDescriptor
                    LLNames.append(FDesc.postscriptName)
                }
                let Parts = Name.split(separator: "-", omittingEmptySubsequences: true)
                if Parts.count == 1
                {
                    Weights.insert("Regular")
                }
                else
                {
                    Weights.insert(String(Parts.last!))
                }
            }
            let NewData = FontData(Family: Family, Weights: Weights.sorted(), LLNames.sorted())
            FontList?.append(NewData)
        }
        FontList?.sort{$0.Family < $1.Family}
        return FontList!
    }
    
    private static var FontList: [FontData]? = nil
    
    /// Verifies a list of separated strings for ASCII-only characters.
    /// - Parameter Raw: List of delimited strings. 
    /// - Parameter Separator: The string used to separate sub-strings. Also used to recombine ASCII-only sub-strings.
    /// - Returns: String with all sub-strings with non-ASCII characters removed.
    public static func ValidateKVPForASCIIOnly(_ Raw: String, Separator: String) -> String
    {
        let WordParts = Raw.split(separator: Separator.first!, omittingEmptySubsequences: true)
        var Words = [String]()
        for WordPart in WordParts
        {
            if String(WordPart).canBeConverted(to: .ascii)
            {
                Words.append(String(WordPart))
            }
        }
        var Result = ""
        for Word in Words
        {
            Result.append(Word)
            Result.append(";")
        }
        return Result
    }
}

enum ImageBorders: String, CaseIterable
{
    case Top = "Top"
    case Left = "Left"
    case Bottom = "Bottom"
    case Right = "Right"
}
