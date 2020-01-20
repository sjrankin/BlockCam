//
//  FontManager.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class FontManager
{
    public static func CustomFont(_ Font: CustomFonts, Size: CGFloat) -> UIFont?
    {
        return UIFont(name: Font.rawValue, size: Size)
    }
}

enum CustomFonts: String, CaseIterable
{
    case NotoSansCJKjp = "NotoSansCJKjp-Black"
    case NotoSerifCJKjp = "NotoSerifCJKjp-Black"
    case NotoSansCJKkr = "NotoSansCJKkr-Black"
    case NotoSerifCJKkr = "NotoSerifCJKkr-Black"
    case NotoSansCJKsc = "NotoSansCJKsc-Black"
    case NotoSerifCJKsc = "NotoSerifCJKsc-Black"
    case NotoSansCJKtc = "NotoSansCJKtc-Black"
    case NotoSerifCJKtc = "NotoSerifCJKtc-Black"
    case NotoSansSymbols = "NotoSansSymbols-Regular"
    case NotoSansSymbols2 = "NotoSansSymbols2-Regular"
}
