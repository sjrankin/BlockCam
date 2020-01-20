//
//  Emoji.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/53388260/how-to-get-all-available-emojis-in-an-array-in-swift
class Emoji
{
    public static func Initialize()
    {
        CreateUnicodeList()
        Log.Message("Found \(UnicodeList.count) unicode characters.")
    }
    
    public static var UnicodeList: [Character] = []
    
    private static func IsInEmojiRange(_ Index: Int) -> Bool
    {
        switch Index
        {
            case 0x1f600 ... 0x1f64f, //Emoticons
            0x1F300 ... 0x1F5FF, // Misc Symbols and Pictographs
            0x1F680 ... 0x1F6FF, // Transport and Map
            0x1F1E6 ... 0x1F1FF, // Regional country flags
            0x2600 ... 0x26FF,   // Misc symbols 9728 - 9983
            0x2700 ... 0x27BF,   // Dingbats
            0xFE00 ... 0xFE0F,   // Variation Selectors
            0x1F900 ... 0x1F9FF,  // Supplemental Symbols and Pictographs 129280 - 129535
            0x1F018 ... 0x1F270, // Various asian characters           127000...127600
            65024 ... 65039, // Variation selector
            9100 ... 9300, // Misc items
            8400 ... 8447: // Combining Diacritical Marks for Symbols
                return true
            
            default:
                return false
        }
    }
    
    private static func CreateUnicodeList()
    {
        for Index in 8400 ... 0x1f9ff where IsInEmojiRange(Index)
        {
            if let Scalar = UnicodeScalar(Index)
            {
                let Unicode = Character(Scalar)
                if Unicode.IsAvailable()
                {
                    UnicodeList.append(Unicode)
                }
            }
        }
    }
}


