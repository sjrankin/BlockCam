//
//  UnicodeBlocks.swift
//  BlockCam
//  Adapted from Characterizer
//
//  Created by Stuart Rankin on 11/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class UnicodeHelper
{
    public static func Initialize()
    {
        InitializeUnicodeBlocks()
    }
    
    public static var UnicodeBlockList: [UnicodeBlock] = []
    
    static func InitializeUnicodeBlocks()
    {
        UnicodeBlockList.removeAll()
        UnicodeBlockList.append(UnicodeBlock("Basic Latin", 0x0000, 0x007f, .BasicLatin))
        UnicodeBlockList.append(UnicodeBlock("Latin-1 Supplement", 0x0080, 0x00ff, .Latin1Supplement))
        UnicodeBlockList.append(UnicodeBlock("Latin Extended-A", 0x0100, 0x017f, .LatinExtendedA))
        UnicodeBlockList.append(UnicodeBlock("Latin Extended-B", 0x0180, 0x024f, .LatinExtendedB))
        UnicodeBlockList.append(UnicodeBlock("IPA Extensions", 0x0250, 0x02af, .IPAExtensions))
        UnicodeBlockList.append(UnicodeBlock("Spacing Modifier Letters", 0x02b0, 0x02ff, .SpacingModifierLetters))
        UnicodeBlockList.append(UnicodeBlock("Combining Diacritical Marks", 0x0300, 0x36f, .CombiningDiacriticalMarks))
        UnicodeBlockList.append(UnicodeBlock("Greek and Coptic", 0x0370, 0x03ff, .GreekAndCoptic))
        UnicodeBlockList.append(UnicodeBlock("Cyrillic", 0x0400, 0x04ff, .Cyrillic))
        UnicodeBlockList.append(UnicodeBlock("Cyrillic Supplement", 0x0500, 0x052f, .CyrillicSupplement))
        UnicodeBlockList.append(UnicodeBlock("Armenian", 0x0530, 0x058f, .Armenian))
        UnicodeBlockList.append(UnicodeBlock("Hebrew", 0x0590, 0x05ff, .Hebrew))
        UnicodeBlockList.append(UnicodeBlock("Arabic", 0x0600, 0x06ff, .Arabic))
        UnicodeBlockList.append(UnicodeBlock("Syriac", 0x0700, 0x074f, .Syriac))
        UnicodeBlockList.append(UnicodeBlock("Arabic Supplement", 0x0750, 0x077f, .ArabicSupplement))
        UnicodeBlockList.append(UnicodeBlock("Thaana", 0x0780, 0x07bf, .Thaana))
        UnicodeBlockList.append(UnicodeBlock("NKo", 0x07c0, 0x07ff, .NKo))
        UnicodeBlockList.append(UnicodeBlock("Samaritan", 0x0800, 0x083f, .Samaritan))
        UnicodeBlockList.append(UnicodeBlock("Mandaic", 0x0840, 0x085f, .Mandaic))
        UnicodeBlockList.append(UnicodeBlock("Arabic Supplement", 0x0860, 0x086f, .ArabicSupplement))
        UnicodeBlockList.append(UnicodeBlock("Arabic Extended-A", 0x08a0, 0x08ff, .ArabicExtendedA))
        UnicodeBlockList.append(UnicodeBlock("Devanagari", 0x0900, 0x097f, .Devanagari))
        UnicodeBlockList.append(UnicodeBlock("Bengali", 0x0980, 0x09ff, .Bengali))
        UnicodeBlockList.append(UnicodeBlock("Gurmukhi", 0x0a00, 0x0a7f, .Gurhukhi))
        UnicodeBlockList.append(UnicodeBlock("Gujarati", 0x0a80, 0x0aff, .Gujarati))
        UnicodeBlockList.append(UnicodeBlock("Oriya", 0x0b00, 0x0b7f, .Oriya))
        UnicodeBlockList.append(UnicodeBlock("Tamil", 0x0b80, 0x00bff, .Tamil))
        UnicodeBlockList.append(UnicodeBlock("Telugu", 0x0c00, 0x0c7f, .Telugu))
        UnicodeBlockList.append(UnicodeBlock("Kannada", 0x0c80, 0x0cff, .Kannada))
        UnicodeBlockList.append(UnicodeBlock("Malayalam", 0x0d00, 0x0d7f, .Malayalam))
        UnicodeBlockList.append(UnicodeBlock("Sinhala", 0x0d80, 0x0dff, .Sinhala))
        UnicodeBlockList.append(UnicodeBlock("Thai", 0x0e00, 0x0e7f, .Thai))
        UnicodeBlockList.append(UnicodeBlock("Lao", 0x0e80, 0x0eff, .Lao))
        UnicodeBlockList.append(UnicodeBlock("Tibetan", 0x0f00, 0x0fff, .Tibetan))
        UnicodeBlockList.append(UnicodeBlock("Myanmar", 0x1000, 0x109f, .Mayanmar))
        UnicodeBlockList.append(UnicodeBlock("Georgian", 0x10a0, 0x10ff, .Georgian))
        UnicodeBlockList.append(UnicodeBlock("Hangul Jamo", 0x1100, 0x11ff, .HangulJamo))
        UnicodeBlockList.append(UnicodeBlock("Ethiopic", 0x1200, 0x137f, .Ethiopic))
        UnicodeBlockList.append(UnicodeBlock("Ethiopic Supplement", 0x1380, 0x139f, .EthiopicSupplement))
        UnicodeBlockList.append(UnicodeBlock("Cherokee", 0x13a0, 0x13ff, .Cherokee))
        UnicodeBlockList.append(UnicodeBlock("Unified Canadian Aboriginal Syllabic", 0x1400, 0x167f, .UnifiedCanadianAboriginalSyllabic))
        UnicodeBlockList.append(UnicodeBlock("Ogham", 0x1680, 0x169f, .Ogham))
        UnicodeBlockList.append(UnicodeBlock("Runic", 0x16a0, 0x16ff, .Runic))
        UnicodeBlockList.append(UnicodeBlock("Tagalog", 0x1700, 0x171f, .Tagalog))
        UnicodeBlockList.append(UnicodeBlock("Hanunoo", 0x1720, 0x173f, .Hanunoo))
        UnicodeBlockList.append(UnicodeBlock("Buhid", 0x1740, 0x175f, .Buhid))
        UnicodeBlockList.append(UnicodeBlock("Tagbanwa", 0x1760, 0x177f, .Tagbanwa))
        UnicodeBlockList.append(UnicodeBlock("Khmer", 0x1780, 0x17ff, .Khmer))
        UnicodeBlockList.append(UnicodeBlock("Mongolian", 0x1800, 0x18af, .Mongolian))
        UnicodeBlockList.append(UnicodeBlock("Unified Canadian Aboriginal Syllabics Extended", 0x18b0, 0x18ff, .UnifiedCanadianAboriginalSyllabicsExtended))
        UnicodeBlockList.append(UnicodeBlock("Limbu", 0x1900, 0x194f, .Limbu))
        UnicodeBlockList.append(UnicodeBlock("Tai Le", 0x1950, 0x197f, .TaiLe))
        UnicodeBlockList.append(UnicodeBlock("New Tai Lue", 0x1980, 0x19df, .NewTaiLue))
        UnicodeBlockList.append(UnicodeBlock("Khmer Symbols", 0x19e0, 0x19ff, .KhmerSymbols))
        UnicodeBlockList.append(UnicodeBlock("Buginese", 0x1a00, 0x1a1f, .Buginese))
        UnicodeBlockList.append(UnicodeBlock("Tai Tham", 0x1a20, 0x1aaf, .TaiTham))
        UnicodeBlockList.append(UnicodeBlock("Combining Diacritical Marks Extended", 0x1ab0, 0x1aff, .CombiningDiacriticalMarksExtended))
        UnicodeBlockList.append(UnicodeBlock("Balinese", 0x1b00, 0x1b7f, .Balinese))
        UnicodeBlockList.append(UnicodeBlock("Sudanese", 0x1b80, 0x1b7f, .Sudanese))
        UnicodeBlockList.append(UnicodeBlock("Batak", 0x1bc0, 0x1bff, .Batak))
        UnicodeBlockList.append(UnicodeBlock("Lepcha", 0x1c00, 0x1c4f, .Lepcha))
        UnicodeBlockList.append(UnicodeBlock("Ol Chiki", 0x1c50, 0x1c7f, .OlChiki))
        UnicodeBlockList.append(UnicodeBlock("Cyrillic Extended-C", 0x1c80, 0x1c8f, .CyrillicExtendedC))
        UnicodeBlockList.append(UnicodeBlock("Georgian Extended", 0x1c90, 0x1cbf, .GeorgianExtended))
        UnicodeBlockList.append(UnicodeBlock("Sudanese Supplement", 0x1cc0, 0x1ccf, .SudaneseSupplement))
        UnicodeBlockList.append(UnicodeBlock("Vedic Extensions", 0x1cd0, 0x1cff, .VedicExtensions))
        UnicodeBlockList.append(UnicodeBlock("Phonetic Extensions", 0x1d00, 0x1d7f, .PhoneticExtensions))
        UnicodeBlockList.append(UnicodeBlock("Phonetic Extensions Supplement", 0x1d80, 0x1dbf, .PhoneticExtensionsSupplement))
        UnicodeBlockList.append(UnicodeBlock("Combining Diacritical Marks Supplement", 0x1dc0, 0x1dff, .CombinginDiacriticalMarksSupplement))
        UnicodeBlockList.append(UnicodeBlock("Latin Extended Additional", 0x1e00, 0x1eff, .LatinExtendedAdditional))
        UnicodeBlockList.append(UnicodeBlock("Greek Extended", 0x1f00, 0x1fff, .GreekExtended))
        UnicodeBlockList.append(UnicodeBlock("General Punctuation", 0x2000, 0x206f, .GeneralPunctuation))
        UnicodeBlockList.append(UnicodeBlock("Supercripts and Subscripts", 0x2070, 0x209f, .SuperscriptsAndSubscripts))
        UnicodeBlockList.append(UnicodeBlock("Currency Symbols", 0x20a0, 0x20cf, .CurrencySymbols))
        UnicodeBlockList.append(UnicodeBlock("Combiningg Diacritical Marks for Symbols", 0x20d0, 0x20ff, .CombiningDiacriticalMarksForSymbols))
        UnicodeBlockList.append(UnicodeBlock("Letterlike Symbols", 0x2100, 0x214f, .LetterlikeSymbols))
        UnicodeBlockList.append(UnicodeBlock("Number Forms", 0x2150, 0x218f, .NumberForms))
        UnicodeBlockList.append(UnicodeBlock("Arrows", 0x2190, 0x21ff, .Arrows))
        UnicodeBlockList.append(UnicodeBlock("Mathematical Operators", 0x2200, 0x22ff, .MathematicalOperators))
        UnicodeBlockList.append(UnicodeBlock("Miscellaneous Technical", 0x2300, 0x23ff, .MiscellaneousTechnical))
        UnicodeBlockList.append(UnicodeBlock("Control Pictures", 0x2400, 0x243f, .ControlPictures))
        UnicodeBlockList.append(UnicodeBlock("Optical Character Recognition", 0x2440, 0x245f, .OpticalCharacterRecognition))
        UnicodeBlockList.append(UnicodeBlock("Enclosed Alphanumerics", 0x2460, 0x24ff, .EnclosedAlphanumerics))
        UnicodeBlockList.append(UnicodeBlock("Box Drawing", 0x2500, 0x257f, .BoxDrawing))
        UnicodeBlockList.append(UnicodeBlock("Block Elements", 0x2580, 0x259f, .BlockElements))
        UnicodeBlockList.append(UnicodeBlock("Geometric Shapes", 0x25a0, 0x25ff, .GeometicShapes))
        UnicodeBlockList.append(UnicodeBlock("Miscellaneous Symbols", 0x2600, 0x26ff, .MiscellaneousSymbols))
        UnicodeBlockList.append(UnicodeBlock("Dingbats", 0x2700, 0x27bf, .Dingbats))
        UnicodeBlockList.append(UnicodeBlock("Miscellaneous Mathematical Symbols-A", 0x27c0, 0x27ef, .MiscellaneousMathematicalSymbolsA))
        UnicodeBlockList.append(UnicodeBlock("Supplemental Arrows-A", 0x27f0, 0x27ff, .SupplementalArrowsA))
        UnicodeBlockList.append(UnicodeBlock("Braille Patterns", 0x2800, 0x28ff, .BraillePatterns))
        UnicodeBlockList.append(UnicodeBlock("Supplemental Arrows-B", 0x2900, 0x297f, .SupplementalArrowsB))
        UnicodeBlockList.append(UnicodeBlock("Miscellaneous Mathematical Symbols-B", 0x2980, 0x29ff, .MiscellaneousMathematicalSymbolsB))
        UnicodeBlockList.append(UnicodeBlock("Supplemental Mathematical Operators", 0x2a00, 0x2aff, .SupplementalMathematicalOperators))
        UnicodeBlockList.append(UnicodeBlock("Miscellaneous Symbols and Arrows", 0x2b00, 0x2bff, .MiscellaneousSymbolsAndArrows))
        UnicodeBlockList.append(UnicodeBlock("Glagolitic", 0x2c00, 0x2c5f, .Glagolitic))
        UnicodeBlockList.append(UnicodeBlock("Latin Extended-C", 0x2c60, 0x2c7f, .LatinExtendedC))
        UnicodeBlockList.append(UnicodeBlock("Coptic", 0x2c80, 0x2cff, .Coptic))
        UnicodeBlockList.append(UnicodeBlock("Georgian Supplement", 0x2d00, 0x2d2f, .GeorgianSupplement))
        UnicodeBlockList.append(UnicodeBlock("Tifinagh", 0x2d30, 0x2d7f, .Tifinagh))
        UnicodeBlockList.append(UnicodeBlock("Ethiopic Extended", 0x2d80, 0x2ddf, .EthiopicExtended))
        UnicodeBlockList.append(UnicodeBlock("Cyrillic Extended-A", 0x2de0, 0x2dff, .CyrillicExtendedA))
        UnicodeBlockList.append(UnicodeBlock("Supplemental Punctuation", 0x2e00, 0x2e7f, .SupplementalPunctuation))
        UnicodeBlockList.append(UnicodeBlock("CJK Radicals Supplement", 0x2e80, 0x2eff, .CJKRadicalsSupplement))
        UnicodeBlockList.append(UnicodeBlock("Kangxi Radicals", 0x2f00, 0x2fdf, .KangxiRadicals))
        UnicodeBlockList.append(UnicodeBlock("Ideographic Description Characters", 0x2ff0, 0x2fff, .IdeographicDescriptionCharacters))
        UnicodeBlockList.append(UnicodeBlock("CJK Symbols and Punctuation", 0x3000, 0x302f, .CJKSymbolsAndPunctuation))
        UnicodeBlockList.append(UnicodeBlock("Hiragana", 0x3040, 0x309f, .Hiragana))
        UnicodeBlockList.append(UnicodeBlock("Katakana", 0x30a0, 0x30ff, .Katakana))
        UnicodeBlockList.append(UnicodeBlock("Bopomofo", 0x3100, 0x312f, .Bopomofo))
        //format changes here because I got tired of hand editing the table
        UnicodeBlockList.append(UnicodeBlock(0x3130,0x318F,Name: "Hangul Compatibility Jamo", .HangulCompatibilityJamo))
        UnicodeBlockList.append(UnicodeBlock(0x3190,0x319F,Name: "Kanbun", .Kanbun))
        UnicodeBlockList.append(UnicodeBlock(0x31A0,0x31BF,Name: "Bopomofo Extended", .BopomofoExtended))
        UnicodeBlockList.append(UnicodeBlock(0x31C0,0x31EF,Name: "CJK Strokes", .CJKStrokes))
        UnicodeBlockList.append(UnicodeBlock(0x31F0,0x31FF,Name: "Katakana Phonetic Extensions", .KatakanaPhoneticExtensions))
        UnicodeBlockList.append(UnicodeBlock(0x3200,0x32FF,Name: "Enclosed CJK Letters and Months", .EnclosedCJKLettersAndMonths))
        UnicodeBlockList.append(UnicodeBlock(0x3300,0x33FF,Name: "CJK Compatibility", .CJKCompatibility))
        UnicodeBlockList.append(UnicodeBlock(0x3400,0x4DBF,Name: "CJK Unified Ideographs Extension A", .CJKUnifiedIdeographsExtensionA))
        UnicodeBlockList.append(UnicodeBlock(0x4DC0,0x4DFF,Name: "Yijing Hexagram Symbols", .YijingHexagramSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x4E00,0x9FFF,Name: "CJK Unified Ideographs", .CJKUnifiedIdeographs))
        UnicodeBlockList.append(UnicodeBlock(0xA000,0xA48F,Name: "Yi Syllables", .YiSyllables))
        UnicodeBlockList.append(UnicodeBlock(0xA490,0xA4CF,Name: "Yi Radicals", .YiRadicals))
        UnicodeBlockList.append(UnicodeBlock(0xA4D0,0xA4FF,Name: "Lisu", .Lisu))
        UnicodeBlockList.append(UnicodeBlock(0xA500,0xA63F,Name: "Vai", .Vai))
        UnicodeBlockList.append(UnicodeBlock(0xA640,0xA69F,Name: "Cyrillic Extended-B", .CyrillicExtendedB))
        UnicodeBlockList.append(UnicodeBlock(0xA6A0,0xA6FF,Name: "Bamum", .Bamum))
        UnicodeBlockList.append(UnicodeBlock(0xA700,0xA71F,Name: "Modifier Tone Letters", .ModifiedToneLetters))
        UnicodeBlockList.append(UnicodeBlock(0xA720,0xA7FF,Name: "Latin Extended-D", .LatinExtendedD))
        UnicodeBlockList.append(UnicodeBlock(0xA800,0xA82F,Name: "Syloti Nagri", .SylotiNagri))
        UnicodeBlockList.append(UnicodeBlock(0xA830,0xA83F,Name: "Common Indic Number Forms", .CommonIndicNumberForms))
        UnicodeBlockList.append(UnicodeBlock(0xA840,0xA87F,Name: "Phags-pa", .Phagspa))
        UnicodeBlockList.append(UnicodeBlock(0xA880,0xA8DF,Name: "Saurashtra", .Saurashtra))
        UnicodeBlockList.append(UnicodeBlock(0xA8E0,0xA8FF,Name: "Devanagari Extended", .Devanagari))
        UnicodeBlockList.append(UnicodeBlock(0xA900,0xA92F,Name: "Kayah Li", .KayahLi))
        UnicodeBlockList.append(UnicodeBlock(0xA930,0xA95F,Name: "Rejang", .Rejang))
        UnicodeBlockList.append(UnicodeBlock(0xA960,0xA97F,Name: "Hangul Jamo Extended-A", .HangulJamoExtendedA))
        UnicodeBlockList.append(UnicodeBlock(0xA980,0xA9DF,Name: "Javanese", .Javanese))
        UnicodeBlockList.append(UnicodeBlock(0xA9E0,0xA9FF,Name: "Myanmar Extended-B", .MyanmarExtendedB))
        UnicodeBlockList.append(UnicodeBlock(0xAA00,0xAA5F,Name: "Cham", .Cham))
        UnicodeBlockList.append(UnicodeBlock(0xAA60,0xAA7F,Name: "Myanmar Extended-A", .MyanmarExtendedA))
        UnicodeBlockList.append(UnicodeBlock(0xAA80,0xAADF,Name: "Tai Viet", .TaiViet))
        UnicodeBlockList.append(UnicodeBlock(0xAAE0,0xAAFF,Name: "Meetei Mayek Extensions", .MeeteiMayekExtensions))
        UnicodeBlockList.append(UnicodeBlock(0xAB00,0xAB2F,Name: "Ethiopic Extended-A", .EthiopicExtendedA))
        UnicodeBlockList.append(UnicodeBlock(0xAB30,0xAB6F,Name: "Latin Extended-E", .LatinExtendedE))
        UnicodeBlockList.append(UnicodeBlock(0xAB70,0xABBF,Name: "Cherokee Supplement", .CherokeeSupplement))
        UnicodeBlockList.append(UnicodeBlock(0xABC0,0xABFF,Name: "Meetei Mayek", .MeeteiMayek))
        UnicodeBlockList.append(UnicodeBlock(0xAC00,0xD7AF,Name: "Hangul Syllables", .HangulSyllables))
        UnicodeBlockList.append(UnicodeBlock(0xD7B0,0xD7FF,Name: "Hangul Jamo Extended-B", .HangulJamoExtendedB))
        UnicodeBlockList.append(UnicodeBlock(0xD800,0xDB7F,Name: "High Surrogates", .HighSurrogates))
        UnicodeBlockList.append(UnicodeBlock(0xDB80,0xDBFF,Name: "High Private Use Surrogates", .HighPrivateUseSurrogates))
        UnicodeBlockList.append(UnicodeBlock(0xDC00,0xDFFF,Name: "Low Surrogates", .LowSurrogates))
        UnicodeBlockList.append(UnicodeBlock(0xE000,0xF8FF,Name: "Private Use Area", .PrivateUseArea))
        UnicodeBlockList.append(UnicodeBlock(0xF900,0xFAFF,Name: "CJK Compatibility Ideographs", .CJKcompatibilityIdeographs))
        UnicodeBlockList.append(UnicodeBlock(0xFB00,0xFB4F,Name: "Alphabetic Presentation Forms", .AlphabeticPresentationForms))
        UnicodeBlockList.append(UnicodeBlock(0xFB50,0xFDFF,Name: "Arabic Presentation Forms-A", .ArabicPresentationFormsA))
        UnicodeBlockList.append(UnicodeBlock(0xFE00,0xFE0F,Name: "Variation Selectors", .VariationSelectors))
        UnicodeBlockList.append(UnicodeBlock(0xFE10,0xFE1F,Name: "Vertical Forms", .VerticalForms))
        UnicodeBlockList.append(UnicodeBlock(0xFE20,0xFE2F,Name: "Combining Half Marks", .CombiningHalfMarks))
        UnicodeBlockList.append(UnicodeBlock(0xFE30,0xFE4F,Name: "CJK Compatibility Forms", .CJKCompatibilityForms))
        UnicodeBlockList.append(UnicodeBlock(0xFE50,0xFE6F,Name: "Small Form Variants", .SmallFormVariants))
        UnicodeBlockList.append(UnicodeBlock(0xFE70,0xFEFF,Name: "Arabic Presentation Forms-B", .ArabicPresentationFormsB))
        UnicodeBlockList.append(UnicodeBlock(0xFF00,0xFFEF,Name: "Halfwidth and Fullwidth Forms", .HalfWidthAndFullWidthForms))
        UnicodeBlockList.append(UnicodeBlock(0xFFF0,0xFFFF,Name: "Specials", .Specials))
        UnicodeBlockList.append(UnicodeBlock(0x10000,0x1007F,Name: "Linear B Syllabary", .LinearBSyllabary))
        UnicodeBlockList.append(UnicodeBlock(0x10080,0x100FF,Name: "Linear B Ideograms", .LinearBIdeograms))
        UnicodeBlockList.append(UnicodeBlock(0x10100,0x1013F,Name: "Aegean Numbers", .AegeanNumbers))
        UnicodeBlockList.append(UnicodeBlock(0x10140,0x1018F,Name: "Ancient Greek Numbers", .AncientGreekNumber))
        UnicodeBlockList.append(UnicodeBlock(0x10190,0x101CF,Name: "Ancient Symbols", .AncientSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x101D0,0x101FF,Name: "Phaistos Disc", .PhaistosDisc))
        UnicodeBlockList.append(UnicodeBlock(0x10280,0x1029F,Name: "Lycian", .Lycian))
        UnicodeBlockList.append(UnicodeBlock(0x102A0,0x102DF,Name: "Carian", .Carian))
        UnicodeBlockList.append(UnicodeBlock(0x102E0,0x102FF,Name: "Coptic Epact Numbers", .CopticEpactNumbers))
        UnicodeBlockList.append(UnicodeBlock(0x10300,0x1032F,Name: "Old Italic", .OldItalic))
        UnicodeBlockList.append(UnicodeBlock(0x10330,0x1034F,Name: "Gothic", .Gothic))
        UnicodeBlockList.append(UnicodeBlock(0x10350,0x1037F,Name: "Old Permic", .OldPermic))
        UnicodeBlockList.append(UnicodeBlock(0x10380,0x1039F,Name: "Ugaritic", .Ugaritic))
        UnicodeBlockList.append(UnicodeBlock(0x103A0,0x103DF,Name: "Old Persian", .OldPersian))
        UnicodeBlockList.append(UnicodeBlock(0x10400,0x1044F,Name: "Deseret", .Deseret))
        UnicodeBlockList.append(UnicodeBlock(0x10450,0x1047F,Name: "Shavian", .Shavian))
        UnicodeBlockList.append(UnicodeBlock(0x10480,0x104AF,Name: "Osmanya", .Osmanya))
        UnicodeBlockList.append(UnicodeBlock(0x104B0,0x104FF,Name: "Osage", .Osage))
        UnicodeBlockList.append(UnicodeBlock(0x10500,0x1052F,Name: "Elbasan", .Elbasan))
        UnicodeBlockList.append(UnicodeBlock(0x10530,0x1056F,Name: "Caucasian Albanian", .CaucasianAlbanian))
        UnicodeBlockList.append(UnicodeBlock(0x10600,0x1077F,Name: "Linear A", .LinearA))
        UnicodeBlockList.append(UnicodeBlock(0x10800,0x1083F,Name: "Cypriot Syllabary", .CypriotSyllabary))
        UnicodeBlockList.append(UnicodeBlock(0x10840,0x1085F,Name: "Imperial Aramaic", .ImperialAramaic))
        UnicodeBlockList.append(UnicodeBlock(0x10860,0x1087F,Name: "Palmyrene", .Palmyrene))
        UnicodeBlockList.append(UnicodeBlock(0x10880,0x108AF,Name: "Nabataean", .Nabataean))
        UnicodeBlockList.append(UnicodeBlock(0x108E0,0x108FF,Name: "Hatran", .Hatran))
        UnicodeBlockList.append(UnicodeBlock(0x10900,0x1091F,Name: "Phoenician", .Phoenician))
        UnicodeBlockList.append(UnicodeBlock(0x10920,0x1093F,Name: "Lydian", .Lydian))
        UnicodeBlockList.append(UnicodeBlock(0x10980,0x1099F,Name: "Meroitic Hieroglyphs", .MeroiticHieroglyphs))
        UnicodeBlockList.append(UnicodeBlock(0x109A0,0x109FF,Name: "Meroitic Cursive", .MeroiticCursive))
        UnicodeBlockList.append(UnicodeBlock(0x10A00,0x10A5F,Name: "Kharoshthi", .Kharoshthi))
        UnicodeBlockList.append(UnicodeBlock(0x10A60,0x10A7F,Name: "Old South Arabian", .OldSouthArabian))
        UnicodeBlockList.append(UnicodeBlock(0x10A80,0x10A9F,Name: "Old North Arabian", .OldNorthArabian))
        UnicodeBlockList.append(UnicodeBlock(0x10AC0,0x10AFF,Name: "Manichaean", .Manichaean))
        UnicodeBlockList.append(UnicodeBlock(0x10B00,0x10B3F,Name: "Avestan", .Avestan))
        UnicodeBlockList.append(UnicodeBlock(0x10B40,0x10B5F,Name: "Inscriptional Parthian", .InscriptionalParthian))
        UnicodeBlockList.append(UnicodeBlock(0x10B60,0x10B7F,Name: "Inscriptional Pahlavi", .InscriptionalPahlavi))
        UnicodeBlockList.append(UnicodeBlock(0x10B80,0x10BAF,Name: "Psalter Pahlavi", .PsalterPahlavi))
        UnicodeBlockList.append(UnicodeBlock(0x10C00,0x10C4F,Name: "Old Turkic", .OldTurkic))
        UnicodeBlockList.append(UnicodeBlock(0x10C80,0x10CFF,Name: "Old Hungarian", .OldHungarian))
        UnicodeBlockList.append(UnicodeBlock(0x10D00,0x10D3F,Name: "Hanifi Rohingya", .HanifiRohingya))
        UnicodeBlockList.append(UnicodeBlock(0x10E60,0x10E7F,Name: "Rumi Numeral Symbols", .RumiNumeralSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x10F00,0x10F2F,Name: "Old Sogdian", .OldSogdian))
        UnicodeBlockList.append(UnicodeBlock(0x10F30,0x10F6F,Name: "Sogdian", .Sogdian))
        UnicodeBlockList.append(UnicodeBlock(0x10FE0,0x10FFF,Name: "Elymaic", .Elymaic))
        UnicodeBlockList.append(UnicodeBlock(0x11000,0x1107F,Name: "Brahmi", .Brahmi))
        UnicodeBlockList.append(UnicodeBlock(0x11080,0x110CF,Name: "Kaithi", .Kaithi))
        UnicodeBlockList.append(UnicodeBlock(0x110D0,0x110FF,Name: "Sora Sompeng", .SoraSompeng))
        UnicodeBlockList.append(UnicodeBlock(0x11100,0x1114F,Name: "Chakma", .Chakma))
        UnicodeBlockList.append(UnicodeBlock(0x11150,0x1117F,Name: "Mahajani", .Mahajani))
        UnicodeBlockList.append(UnicodeBlock(0x11180,0x111DF,Name: "Sharada", .Sharada))
        UnicodeBlockList.append(UnicodeBlock(0x111E0,0x111FF,Name: "Sinhala Archaic Numbers", .SinhalaArchaicNumbers))
        UnicodeBlockList.append(UnicodeBlock(0x11200,0x1124F,Name: "Khojki", .Khojki))
        UnicodeBlockList.append(UnicodeBlock(0x11280,0x112AF,Name: "Multani", .Multani))
        UnicodeBlockList.append(UnicodeBlock(0x112B0,0x112FF,Name: "Khudawadi", .Khudawadi))
        UnicodeBlockList.append(UnicodeBlock(0x11300,0x1137F,Name: "Grantha", .Grantha))
        UnicodeBlockList.append(UnicodeBlock(0x11400,0x1147F,Name: "Newa", .Newa))
        UnicodeBlockList.append(UnicodeBlock(0x11480,0x114DF,Name: "Tirhuta", .Tirhuta))
        UnicodeBlockList.append(UnicodeBlock(0x11580,0x115FF,Name: "Siddham", .Siddham))
        UnicodeBlockList.append(UnicodeBlock(0x11600,0x1165F,Name: "Modi", .Modi))
        UnicodeBlockList.append(UnicodeBlock(0x11660,0x1167F,Name: "Mongolian Supplement", .MongolianSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x11680,0x116CF,Name: "Takri", .Takri))
        UnicodeBlockList.append(UnicodeBlock(0x11700,0x1173F,Name: "Ahom", .Ahom))
        UnicodeBlockList.append(UnicodeBlock(0x11800,0x1184F,Name: "Dogra", .Dogra))
        UnicodeBlockList.append(UnicodeBlock(0x118A0,0x118FF,Name: "Warang Citi", .WarangCiti))
        UnicodeBlockList.append(UnicodeBlock(0x119A0,0x119FF,Name: "Nandinagari", .Nandinagari))
        UnicodeBlockList.append(UnicodeBlock(0x11A00,0x11A4F,Name: "Zanabazar Square", .ZanabazarSquare))
        UnicodeBlockList.append(UnicodeBlock(0x11A50,0x11AAF,Name: "Soyombo", .Soyombo))
        UnicodeBlockList.append(UnicodeBlock(0x11AC0,0x11AFF,Name: "Pau Cin Hau", .PauCinHau))
        UnicodeBlockList.append(UnicodeBlock(0x11C00,0x11C6F,Name: "Bhaiksuki", .Bhaiksuki))
        UnicodeBlockList.append(UnicodeBlock(0x11C70,0x11CBF,Name: "Marchen", .Marchen))
        UnicodeBlockList.append(UnicodeBlock(0x11D00,0x11D5F,Name: "Masaram Gondi", .MasaramGondi))
        UnicodeBlockList.append(UnicodeBlock(0x11D60,0x11DAF,Name: "Gunjala Gondi", .GunjalaGondi))
        UnicodeBlockList.append(UnicodeBlock(0x11EE0,0x11EFF,Name: "Makasar", .Makasar))
        UnicodeBlockList.append(UnicodeBlock(0x11FC0,0x11FFF,Name: "Tamil Supplement", .TamilSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x12000,0x123FF,Name: "Cuneiform", .Cuneiform))
        UnicodeBlockList.append(UnicodeBlock(0x12400,0x1247F,Name: "Cuneiform Numbers and Punctuation", .CuneiformNumbersAndPunctuation))
        UnicodeBlockList.append(UnicodeBlock(0x12480,0x1254F,Name: "Early Dynastic Cuneiform", .EarlyDynasticCuneiform))
        UnicodeBlockList.append(UnicodeBlock(0x13000,0x1342F,Name: "Egyptian Hieroglyphs", .EgyptianHieroglyphs))
        UnicodeBlockList.append(UnicodeBlock(0x13430,0x1343F,Name: "Egyptian Hieroglyph Format Controls", .EgyptianHieroglyphFormatControls))
        UnicodeBlockList.append(UnicodeBlock(0x14400,0x1467F,Name: "Anatolian Hieroglyphs", .AnatolianHieroglyphs))
        UnicodeBlockList.append(UnicodeBlock(0x16800,0x16A3F,Name: "Bamum Supplement", .BamumSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x16A40,0x16A6F,Name: "Mro", .Mro))
        UnicodeBlockList.append(UnicodeBlock(0x16AD0,0x16AFF,Name: "Bassa Vah", .BassaVah))
        UnicodeBlockList.append(UnicodeBlock(0x16B00,0x16B8F,Name: "Pahawh Hmong", .PahawhHmong))
        UnicodeBlockList.append(UnicodeBlock(0x16E40,0x16E9F,Name: "Medefaidrin", .Medefaidrin))
        UnicodeBlockList.append(UnicodeBlock(0x16F00,0x16F9F,Name: "Miao", .Miao))
        UnicodeBlockList.append(UnicodeBlock(0x16FE0,0x16FFF,Name: "Ideographic Symbols and Punctuation", .IdeographicSymbolsAndPunctuation))
        UnicodeBlockList.append(UnicodeBlock(0x17000,0x187FF,Name: "Tangut", .Tangut))
        UnicodeBlockList.append(UnicodeBlock(0x18800,0x18AFF,Name: "Tangut Components", .TangutComponents))
        UnicodeBlockList.append(UnicodeBlock(0x1B000,0x1B0FF,Name: "Kana Supplement", .KanaSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x1B100,0x1B12F,Name: "Kana Extended-A", .KanaExtendedA))
        UnicodeBlockList.append(UnicodeBlock(0x1B130,0x1B16F,Name: "Small Kana Extension", .SmallKanaExtension))
        UnicodeBlockList.append(UnicodeBlock(0x1B170,0x1B2FF,Name: "Nüshu", .Nushu))
        UnicodeBlockList.append(UnicodeBlock(0x1BC00,0x1BC9F,Name: "Duployan", .Duployan))
        UnicodeBlockList.append(UnicodeBlock(0x1BCA0,0x1BCAF,Name: "Shorthand Format Controls", .ShorthandFormatControls))
        UnicodeBlockList.append(UnicodeBlock(0x1D000,0x1D0FF,Name: "Byzantine Musical Symbols", .ByzantineMusicalSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1D100,0x1D1FF,Name: "Musical Symbols", .MusicalSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1D200,0x1D24F,Name: "Ancient Greek Musical Notation", .AncientGreekMusicalNotation))
        UnicodeBlockList.append(UnicodeBlock(0x1D2E0,0x1D2FF,Name: "Mayan Numerals", .MayanNumerals))
        UnicodeBlockList.append(UnicodeBlock(0x1D300,0x1D35F,Name: "Tai Xuan Jing Symbols", .TaiXuanJingSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1D360,0x1D37F,Name: "Counting Rod Numerals", .CountingRodNumerals))
        UnicodeBlockList.append(UnicodeBlock(0x1D400,0x1D7FF,Name: "Mathematical Alphanumeric Symbols", .MathematicalAlphanumericSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1D800,0x1DAAF,Name: "Sutton SignWriting", .SuttonSignWriting))
        UnicodeBlockList.append(UnicodeBlock(0x1E000,0x1E02F,Name: "Glagolitic Supplement", .GlagoliticSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x1E100,0x1E14F,Name: "Nyiakeng Puachue Hmong", .NyiakengPauchueHmong))
        UnicodeBlockList.append(UnicodeBlock(0x1E2C0,0x1E2FF,Name: "Wancho", .Wancho))
        UnicodeBlockList.append(UnicodeBlock(0x1E800,0x1E8DF,Name: "Mende Kikakui", .MendeKikakui))
        UnicodeBlockList.append(UnicodeBlock(0x1E900,0x1E95F,Name: "Adlam", .Adlam))
        UnicodeBlockList.append(UnicodeBlock(0x1EC70,0x1ECBF,Name: "Indic Siyaq Numbers", .IndicSiyaqNumbers))
        UnicodeBlockList.append(UnicodeBlock(0x1ED00,0x1ED4F,Name: "Ottoman Siyaq Numbers", .OttomanSiyaqNumbers))
        UnicodeBlockList.append(UnicodeBlock(0x1EE00,0x1EEFF,Name: "Arabic Mathematical Alphabetic Symbols", .ArabicMathematicalAlphabeticalSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1F000,0x1F02F,Name: "Mahjong Tiles", .Mahjongtiles))
        UnicodeBlockList.append(UnicodeBlock(0x1F030,0x1F09F,Name: "Domino Tiles", .DominoTiles))
        UnicodeBlockList.append(UnicodeBlock(0x1F0A0,0x1F0FF,Name: "Playing Cards", .PlayingCards))
        UnicodeBlockList.append(UnicodeBlock(0x1F100,0x1F1FF,Name: "Enclosed Alphanumeric Supplement", .EnclosedAlphanumericSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x1F200,0x1F2FF,Name: "Enclosed Ideographic Supplement", .EnclosedIdeographicSupplement))
        UnicodeBlockList.append(UnicodeBlock(0x1F300,0x1F5FF,Name: "Miscellaneous Symbols and Pictographs", .MiscellaneousSymbolsAndPictographs))
        UnicodeBlockList.append(UnicodeBlock(0x1F600,0x1F64F,Name: "Emoticons", .Emoticons))
        UnicodeBlockList.append(UnicodeBlock(0x1F650,0x1F67F,Name: "Ornamental Dingbats", .OrnamentalDingbats))
        UnicodeBlockList.append(UnicodeBlock(0x1F680,0x1F6FF,Name: "Transport and Map Symbols", .TransportAndMapSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1F700,0x1F77F,Name: "Alchemical Symbols", .AlchemicalSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1F780,0x1F7FF,Name: "Geometric Shapes Extended", .GeometicShapesExtended))
        UnicodeBlockList.append(UnicodeBlock(0x1F800,0x1F8FF,Name: "Supplemental Arrows-C", .SupplementArrowsC))
        UnicodeBlockList.append(UnicodeBlock(0x1F900,0x1F9FF,Name: "Supplemental Symbols and Pictographs", .SupplementalSymbolsAndPictographs))
        UnicodeBlockList.append(UnicodeBlock(0x1FA00,0x1FA6F,Name: "Chess Symbols", .ChessSymbols))
        UnicodeBlockList.append(UnicodeBlock(0x1FA70,0x1FAFF,Name: "Symbols and Pictographs Extended-A", .SymbolsAndPictographsExtendedA))
        UnicodeBlockList.append(UnicodeBlock(0x20000,0x2A6DF,Name: "CJK Unified Ideographs Extension B", .CJKUnifiedIdeographsExtensionB))
        UnicodeBlockList.append(UnicodeBlock(0x2A700,0x2B73F,Name: "CJK Unified Ideographs Extension C", .CJKUnifiedIdeographsExtensionC))
        UnicodeBlockList.append(UnicodeBlock(0x2B740,0x2B81F,Name: "CJK Unified Ideographs Extension D", .CJKUnifiedIdeographsExtensionD))
        UnicodeBlockList.append(UnicodeBlock(0x2B820,0x2CEAF,Name: "CJK Unified Ideographs Extension E", .CJKUnifiedIdeographsExtensionE))
        UnicodeBlockList.append(UnicodeBlock(0x2CEB0,0x2EBEF,Name: "CJK Unified Ideographs Extension F", .CJKUnifiedIdeographsExtensionF))
        UnicodeBlockList.append(UnicodeBlock(0x2F800,0x2FA1F,Name: "CJK Compatibility Ideographs Supplement", .CJKCompatibilityIdeographsSupplement))
        UnicodeBlockList.append(UnicodeBlock(0xE0000,0xE007F,Name: "Tags", .Tags))
        UnicodeBlockList.append(UnicodeBlock(0xE0100,0xE01EF,Name: "Variation Selectors Supplement", .VariationSelectorsSupplement))
        UnicodeBlockList.append(UnicodeBlock(0xF0000,0xFFFFF,Name: "Supplementary Private Use Area-A", .SupplementaryPrivateUseAreaB))
        UnicodeBlockList.append(UnicodeBlock(0x100000,0x10FFFF,Name: "Supplementary Private Use Area-B", .SupplementaryPrivateUseAreaB))
    }
}

enum UnicodeRanges: String, CaseIterable
{
    case BasicLatin = "Basic Latin"
    case Latin1Supplement = "Latin-1 Supplement"
    case LatinExtendedA = "Latin Extended-A"
    case LatinExtendedB = "Latin Extended-B"
    case IPAExtensions = "IPA Extensions"
    case SpacingModifierLetters = "Spacing Modifier Letters"
    case CombiningDiacriticalMarks = "Combining Diacritical Marks"
    case GreekAndCoptic = "Greek and Coptic"
    case Cyrillic = "Cyrillic"
    case CyrillicSupplement = "Cyrillic Supplement"
    case Armenian = "Armenian"
    case Hebrew = "Hebrew"
    case Arabic = "Arabic"
    case Syriac = "Syriac"
    case ArabicSupplement = "Arabic Supplement"
    case Thaana = "Thaana"
    case NKo = "NKo"
    case Samaritan = "Samaritan"
    case Mandaic = "Mandaic"
    case CyriacSupplement = "Syriac Supplement"
    case ArabicExtendedA = "Arabic Extended-A"
    case Devanagari = "Devanagari"
    case Bengali = "Bengali"
    case Gurhukhi = "Gurmukhi"
    case Gujarati = "Gujarati"
    case Oriya = "Oriya"
    case Tamil = "Tamil"
    case Telugu = "Telugu"
    case Kannada = "Kannada"
    case Malayalam = "Malayalam"
    case Sinhala = "Sinhala"
    case Thai = "Thai"
    case Lao = "Lao"
    case Tibetan = "Tibetan"
    case Mayanmar = "Myanmar"
    case Georgian = "Georgian"
    case HangulJamo = "Hangul Jamo"
    case Ethiopic = "Ethiopic"
    case EthiopicSupplement = "Ehtiopic Supplement"
    case Cherokee = "Cherokee"
    case UnifiedCanadianAboriginalSyllabic = "Unified Canadian Aboriginal Syllabic"
    case Ogham = "Ogham"
    case Runic = "Runic"
    case Tagalog = "Tagalog"
    case Hanunoo = "Hanunoo"
    case Buhid = "Buhid"
    case Tagbanwa = "Tagbanwa"
    case Khmer = "Khmer"
    case Mongolian = "Mongolian"
    case UnifiedCanadianAboriginalSyllabicsExtended = "Unified Canadian Aboriginal Syllabics Extended"
    case Limbu = "Limbu"
    case TaiLe = "Tai Le"
    case NewTaiLue = "New Tai Lue"
    case KhmerSymbols = "Khmer Symbols"
    case Buginese = "Buginese"
    case TaiTham = "Tai Tham"
    case CombiningDiacriticalMarksExtended = "Combining Diacritical Marks Extended"
    case Balinese = "Balinese"
    case Sudanese = "Sudanese"
    case Batak = "Batak"
    case Lepcha = "Lepcha"
    case OlChiki = "Ol Chiki"
    case CyrillicExtendedC = "Cyrillic Extended-C"
    case GeorgianExtended = "Georgian Extended"
    case SudaneseSupplement = "Sudanese Supplement"
    case VedicExtensions = "Vedic Extensions"
    case PhoneticExtensions = "Phonetic Extensions"
    case PhoneticExtensionsSupplement = "Phonetic Extensions Supplement"
    case CombinginDiacriticalMarksSupplement = "Combining Diacritical Marks Supplement"
    case LatinExtendedAdditional = "Latin Extended Additional"
    case GreekExtended = "Greek Extended"
    case GeneralPunctuation = "General Punctuation"
    case SuperscriptsAndSubscripts = "Supercripts and Subscripts"
    case CurrencySymbols = "Currency Symbols"
    case CombiningDiacriticalMarksForSymbols = "Combing Diacritical Marks for Symbols"
    case LetterlikeSymbols = "Letterlike Symbols"
    case NumberForms = "Number Forms"
    case Arrows = "Arrows"
    case MathematicalOperators = "Mathematical Operators"
    case MiscellaneousTechnical = "Miscellaneous Technical"
    case ControlPictures = "Control Pictures"
    case OpticalCharacterRecognition = "Optical Character Recognition"
    case EnclosedAlphanumerics = "Enclosed Alphanumerics"
    case BoxDrawing = "Box Drawing"
    case BlockElements = "Block Elements"
    case GeometicShapes = "Geometric Shapes"
    case MiscellaneousSymbols = "Miscellaneous Symbols"
    case Dingbats = "Dingbats"
    case MiscellaneousMathematicalSymbolsA = "Miscellaneous Mathematical Symbols-A"
    case SupplementalArrowsA = "Supplemental Arrows-A"
    case BraillePatterns = "Braille Patterns"
    case SupplementalArrowsB = "Supplemental Arrows-B"
    case MiscellaneousMathematicalSymbolsB = "Miscellaneous Mathematical Symbols-B"
    case SupplementalMathematicalOperators = "Supplemental Mathematical Operators"
    case MiscellaneousSymbolsAndArrows = "Miscellaneous Symbols and Arrows"
    case Glagolitic = "Glagolitic"
    case LatinExtendedC = "Latin Extended-C"
    case Coptic = "Coptic"
    case GeorgianSupplement = "Georgian Supplement"
    case Tifinagh = "Tifinagh"
    case EthiopicExtended = "Ethiopic Extended"
    case CyrillicExtendedA = "Cyrillic Extended-A"
    case SupplementalPunctuation = "Supplemental Punctuation"
    case CJKRadicalsSupplement = "CJK Radicals Supplement"
    case KangxiRadicals = "Kangxi Radicals"
    case IdeographicDescriptionCharacters = "Ideographic Description Characters"
    case CJKSymbolsAndPunctuation = "CJK Symbols and Punctuation"
    case Hiragana = "Hiragana"
    case Katakana = "Katakana"
    case Bopomofo = "Bopomofo"
    case HangulCompatibilityJamo = "Hangul Compatibility Jamo"
    case Kanbun = "Kanbun"
    case BopomofoExtended = "Bopomofo Extended"
    case CJKStrokes = "CJK Strokes"
    case KatakanaPhoneticExtensions = "Katakana Phonetic Extensions"
    case EnclosedCJKLettersAndMonths = "Enclosed CJK Letters and Months"
    case CJKCompatibility = "CJK Compatibility"
    case CJKUnifiedIdeographsExtensionA = "CJK Unified Ideographs Extension A"
    case YijingHexagramSymbols = "Yijing Hexagram Symbols"
    case CJKUnifiedIdeographs = "CJK Unified Ideographs"
    case YiSyllables = "Yi Syllables"
    case YiRadicals = "Yi Radicals"
    case Lisu = "Lisu"
    case Vai = "Vai"
    case CyrillicExtendedB = "Cyrillic Extended-B"
    case Bamum = "Bamum"
    case ModifiedToneLetters = "Modifier Tone Letters"
    case LatinExtendedD = "Latin Extended-D"
    case SylotiNagri = "Syloti Nagri"
    case CommonIndicNumberForms = "Common Indic Number Forms"
    case Phagspa = "Phags-pa"
    case Saurashtra = "Saurashtra"
    case DevanagariExtended = "Devanagari Extended"
    case KayahLi = "Kayah Li"
    case Rejang = "Rejang"
    case HangulJamoExtendedA = "Hangul Jamo Extended-A"
    case Javanese = "Javanese"
    case MyanmarExtendedB = "Myanmar Extended-B"
    case Cham = "Cham"
    case MyanmarExtendedA = "Myanmar Extended-A"
    case TaiViet = "Tai Viet"
    case MeeteiMayekExtensions = "Meetei Mayek Extensions"
    case EthiopicExtendedA = "Ethiopic Extended-A"
    case LatinExtendedE = "Latin Extended-E"
    case CherokeeSupplement = "Cherokee Supplement"
    case MeeteiMayek = "Meetei Mayek"
    case HangulSyllables = "Hangul Syllables"
    case HangulJamoExtendedB = "Hangul Jamo Extended-B"
    case HighSurrogates = "High Surrogates"
    case HighPrivateUseSurrogates = "High Private Use Surrogates"
    case LowSurrogates = "Low Surrogates"
    case PrivateUseArea = "Private Use Area"
    case CJKcompatibilityIdeographs = "CJK Compatibility Ideographs"
    case AlphabeticPresentationForms = "Alphabetic Presentation Forms"
    case ArabicPresentationFormsA = "Arabic Presentation Forms-A"
    case VariationSelectors = "Variation Selectors"
    case VerticalForms = "Vertical Forms"
    case CombiningHalfMarks = "Combining Half Marks"
    case CJKCompatibilityForms = "CJK Compatibility Forms"
    case SmallFormVariants = "Small Form Variants"
    case ArabicPresentationFormsB = "Arabic Presentation Forms-B"
    case HalfWidthAndFullWidthForms = "Halfwidth and Fullwidth Forms"
    case Specials = "Specials"
    case LinearBSyllabary = "Linear B Syllabary"
    case LinearBIdeograms = "Linear B Ideograms"
    case AegeanNumbers = "Aegean Numbers"
    case AncientGreekNumber = "Ancient Greek Numbers"
    case AncientSymbols = "Ancient Symbols"
    case PhaistosDisc = "Phaistos Disc"
    case Lycian = "Lycian"
    case Carian = "Carian"
    case CopticEpactNumbers = "Coptic Epact Numbers"
    case OldItalic = "Old Italic"
    case Gothic = "Gothic"
    case OldPermic = "Old Permic"
    case Ugaritic = "Ugaritic"
    case OldPersian = "Old Persian"
    case Deseret = "Deseret"
    case Shavian = "Shavian"
    case Osmanya = "Osmanya"
    case Osage = "Osage"
    case Elbasan = "Elbasan"
    case CaucasianAlbanian = "Caucasian Albanian"
    case LinearA = "Linear A"
    case CypriotSyllabary = "Cypriot Syllabary"
    case ImperialAramaic = "Imperial Aramaic"
    case Palmyrene = "Palmyrene"
    case Nabataean = "Nabataean"
    case Hatran = "Hatran"
    case Phoenician = "Phoenician"
    case Lydian = "Lydian"
    case MeroiticHieroglyphs = "Meroitic Hieroglyphs"
    case MeroiticCursive = "Meroitic Cursive"
    case Kharoshthi = "Kharoshthi"
    case OldSouthArabian = "Old South Arabian"
    case OldNorthArabian = "Old North Arabian"
    case Manichaean = "Manichaean"
    case Avestan = "Avestan"
    case InscriptionalParthian = "Inscriptional Parthian"
    case InscriptionalPahlavi = "Inscriptional Pahlavi"
    case PsalterPahlavi = "Psalter Pahlavi"
    case OldTurkic = "Old Turkic"
    case OldHungarian = "Old Hungarian"
    case HanifiRohingya = "Hanifi Rohingya"
    case RumiNumeralSymbols = "Rumi Numeral Symbols"
    case OldSogdian = "Old Sogdian"
    case Sogdian = "Sogdian"
    case Elymaic = "Elymaic"
    case Brahmi = "Brahmi"
    case Kaithi = "Kaithi"
    case SoraSompeng = "Sora Sompeng"
    case Chakma = "Chakma"
    case Mahajani = "Mahajani"
    case Sharada = "Sharada"
    case SinhalaArchaicNumbers = "Sinhala Archaic Numbers"
    case Khojki = "Khojki"
    case Multani = "Multani"
    case Khudawadi = "Khudawadi"
    case Grantha = "Grantha"
    case Newa = "Newa"
    case Tirhuta = "Tirhuta"
    case Siddham = "Siddham"
    case Modi = "Modi"
    case MongolianSupplement = "Mongolian Supplement"
    case Takri = "Takri"
    case Ahom = "Ahom"
    case Dogra = "Dogra"
    case WarangCiti = "Warang Citi"
    case Nandinagari = "Nandinagari"
    case ZanabazarSquare = "Zanabazar Square"
    case Soyombo = "Soyombo"
    case PauCinHau = "Pau Cin Hau"
    case Bhaiksuki = "Bhaiksuki"
    case Marchen = "Marchen"
    case MasaramGondi = "Masaram Gondi"
    case GunjalaGondi = "Gunjala Gondi"
    case Makasar = "Makasar"
    case TamilSupplement = "Tamil Supplement"
    case Cuneiform = "Cuneiform"
    case CuneiformNumbersAndPunctuation = "Cuneiform Numbers and Punctuation"
    case EarlyDynasticCuneiform = "Early Dynastic Cuneiform"
    case EgyptianHieroglyphs = "Egyptian Hieroglyphs"
    case EgyptianHieroglyphFormatControls = "Egyptian Hieroglyph Format Controls"
    case AnatolianHieroglyphs = "Anatolian Hieroglyphs"
    case BamumSupplement = "Bamum Supplement"
    case Mro = "Mro"
    case BassaVah = "Bassa Vah"
    case PahawhHmong = "Pahawh Hmong"
    case Medefaidrin = "Medefaidrin"
    case Miao = "Miao"
    case IdeographicSymbolsAndPunctuation = "Ideographic Symbols and Punctuation"
    case Tangut = "Tangut"
    case TangutComponents = "Tangut Components"
    case KanaSupplement = "Kana Supplement"
    case KanaExtendedA = "Kana Extended-A"
    case SmallKanaExtension = "Small Kana Extension"
    case Nushu = "Nüshu"
    case Duployan = "Duployan"
    case ShorthandFormatControls = "Shorthand Format Controls"
    case ByzantineMusicalSymbols = "Byzantine Musical Symbols"
    case MusicalSymbols = "Musical Symbols"
    case AncientGreekMusicalNotation = "Ancient Greek Musical Notation"
    case MayanNumerals = "Mayan Numerals"
    case TaiXuanJingSymbols = "Tai Xuan Jing Symbols"
    case CountingRodNumerals = "Counting Rod Numerals"
    case MathematicalAlphanumericSymbols = "Mathematical Alphanumeric Symbols"
    case SuttonSignWriting = "Sutton SignWriting"
    case GlagoliticSupplement = "Glagolitic Supplement"
    case NyiakengPauchueHmong = "Nyiakeng Puachue Hmong"
    case Wancho = "Wancho"
    case MendeKikakui = "Mende Kikakui"
    case Adlam = "Adlam"
    case IndicSiyaqNumbers = "Indic Siyaq Numbers"
    case OttomanSiyaqNumbers = "Ottoman Siyaq Numbers"
    case ArabicMathematicalAlphabeticalSymbols = "Arabic Mathematical Alphabetic Symbols"
    case Mahjongtiles = "Mahjong Tiles"
    case DominoTiles = "Domino Tiles"
    case PlayingCards = "Playing Cards"
    case EnclosedAlphanumericSupplement = "Enclosed Alphanumeric Supplement"
    case EnclosedIdeographicSupplement = "Enclosed Ideographic Supplement"
    case MiscellaneousSymbolsAndPictographs = "Miscellaneous Symbols and Pictographs"
    case Emoticons = "Emoticons"
    case OrnamentalDingbats = "Ornamental Dingbats"
    case TransportAndMapSymbols = "Transport and Map Symbols"
    case AlchemicalSymbols = "Alchemical Symbols"
    case GeometicShapesExtended = "Geometric Shapes Extended"
    case SupplementArrowsC = "Supplemental Arrows-C"
    case SupplementalSymbolsAndPictographs = "Supplemental Symbols and Pictographs"
    case ChessSymbols = "Chess Symbols"
    case SymbolsAndPictographsExtendedA = "Symbols and Pictographs Extended-A"
    case CJKUnifiedIdeographsExtensionB = "CJK Unified Ideographs Extension B"
    case CJKUnifiedIdeographsExtensionC = "CJK Unified Ideographs Extension C"
    case CJKUnifiedIdeographsExtensionD = "CJK Unified Ideographs Extension D"
    case CJKUnifiedIdeographsExtensionE = "CJK Unified Ideographs Extension E"
    case CJKUnifiedIdeographsExtensionF = "CJK Unified Ideographs Extension F"
    case CJKCompatibilityIdeographsSupplement = "CJK Compatibility Ideographs Supplement"
    case Tags = "Tags"
    case VariationSelectorsSupplement = "Variation Selectors Supplement"
    case SupplementaryPrivateUseAreaA = "Supplementary Private Use Area-A"
    case SupplementaryPrivateUseAreaB = "Supplementary Private Use Area-B"
}
