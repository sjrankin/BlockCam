//
//  StringMapping.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maps from enums to internationalized strings.
class StringMapping
{
    /// Given an enum, return a string key to use to retrieve a localized string.
    /// - Note: Fatal errors are generated for any missing table entries or incorrect type casts.
    /// - Parameter For: The enum case whose localized string key will be returned.
    /// - Returns: Key to use to retrieve the localized string for the passed enum case value.
    public static func LocalizedString<T>(For: T) -> String where T: CaseIterable & Equatable
    {
        if type(of: For) == .some(ShapeSeries.self)
        {
            if let ShapeSeriesName = For as? ShapeSeries
            {
                if let Name = CharacterSetMap[ShapeSeriesName]
                {
                    return Name
                }
                else
                {
                    fatalError("Did not find \(ShapeSeriesName) in CharacterSetMap")
                }
            }
            else
            {
                fatalError("Unable to convert For to ShapeSeries.")
            }
        }
        fatalError("No mapping available for \(For)")
    }
    
    public static let CharacterSetMap =
    [
        ShapeSeries.Flowers: "CharacterSetNameFlowers",
        ShapeSeries.Snowflakes: "CharacterSetNameSnowflakes",
        ShapeSeries.Arrows: "CharacterSetNameArrows",
        ShapeSeries.SmallGeometry: "CharacterSetNameGeometric",
        ShapeSeries.Stars: "CharacterSetNameStars",
        ShapeSeries.Ornamental: "CharacterSetNameOrnamental",
        ShapeSeries.Things: "CharacterSetNameThings",
        ShapeSeries.Computers: "CharacterSetNameComputerRelated",
        ShapeSeries.Hiragana: "CharacterSetNameHiragana",
        ShapeSeries.Katakana: "CharacterSetNameKatakana",
        ShapeSeries.KyoikuKanji: "CharacterSetNameKanji",
        ShapeSeries.Hangul: "CharacterSetNameHangul",
        ShapeSeries.Bodoni: "CharacterSetNameBodoni",
        ShapeSeries.Latin: "CharacterSetNameLatin",
        ShapeSeries.Greek: "CharacterSetNameGreek",
        ShapeSeries.Cyrillic: "CharacterSetNameCyrillic",
        ShapeSeries.Emoji: "CharacterSetNameEmoji",
        ShapeSeries.Punctuation: "CharacterSetNamePunctuation",
        ShapeSeries.BoxSymbols: "CharacterSetNameBoxSymbols"
    ]
}
