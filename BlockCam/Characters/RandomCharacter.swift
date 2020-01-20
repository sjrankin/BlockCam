//
//  RandomCharacter.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Handles generation of random characters.
class RandomCharacter
{
    /// Return a random character from the specified Unicode range.
    /// - Parameter FromRange: The Unicode range from which to return a random character.
    /// - Parameter InFont: The font to use to determine whether a glyph exists or not.
    /// - Returns: A random character from within the specified Unicode block range. If the glyph does not exist, nil is returned.
    public static func Get(FromRange: UnicodeRanges, InFont: UIFont) -> String?
    {
        return Get(FromRanges: [FromRange], InFont: InFont)
    }
    
    /// Return a random character from the specified Unicode range.
    /// - Parameter FromRanges: Array of Unicode ranges from which to return a random character.
    /// - Parameter InFont: The font to use to determine whether a glyph exists or not.
    /// - Returns: A random character from within the specified Unicode block range. If the glyph does not exist, nil is returned.
    public static func Get(FromRanges: [UnicodeRanges], InFont: UIFont) -> String?
    {
        var CodePoints = Set<UInt32>()
        for Range in FromRanges
        {
            if let TheBlock = GetBlock(Range)
            {
                for CP in TheBlock.LowRange ... TheBlock.HighRange
                {
                    if CP <= 0x20
                    {
                        //We do not care about control characters
                        continue
                    }
                    let CheckMe = Character(UnicodeScalar(CP)!)
                    if FontContains(Glyph: CheckMe, InFont)
                    {
                        CodePoints.insert(CP)
                    }
                }
            }
        }
        if CodePoints.count == 0
        {
            return nil
        }
        let RandomCodePoint = CodePoints.randomElement()!
        let Final = String(Character(UnicodeScalar(RandomCodePoint)!))
        return Final
    }
    
    /// Returns a Unicode Block set of information.
    /// - Parameter Block: The block ID.
    /// - Returns: If found, the specified block of information. If not found, nil.
    public static func GetBlock(_ Block: UnicodeRanges) -> UnicodeBlock?
    {
        for SomeBlock in UnicodeHelper.UnicodeBlockList
        {
            if SomeBlock.UnicodeBlockID == Block
            {
                return SomeBlock
            }
        }
        return nil
    }
    
    public static func FontContains(Glyph: Character, _ Font: UIFont) -> Bool
    {
        if Font != PreviousFont
        {
            if PreviousFont == nil
            {
                PreviousFont = Font
            }
            FontDescriptor = Font.fontDescriptor
            FontName = FontDescriptor.postscriptName as CFString
            CoreFont = CTFontCreateWithName(FontName!, Font.pointSize, nil)
        }
        let Points = Array(Glyph.unicodeScalars)
        let FirstPointView = Points.first!.utf16
        let FirstPointValue = UInt16(FirstPointView.first!)
        var CodePoint: [UniChar] = [FirstPointValue]
        var Glyphs: [CGGlyph] = [0]
        let Found = CTFontGetGlyphsForCharacters(CoreFont, &CodePoint, &Glyphs, Glyphs.count)
        return Found
    }
    
    private static var PreviousFont: UIFont? = nil
    private static var FontDescriptor: UIFontDescriptor!
    private static var FontName: CFString!
    private static var CoreFont: CTFont!
}
