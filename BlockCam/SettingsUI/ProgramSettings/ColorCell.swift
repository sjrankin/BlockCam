//
//  ColorCell.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/11/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ColorSample = UIView(frame: CGRect(x: 5, y: 2, width: 100, height: 46))
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.cornerRadius = 5.0
        ColorSample.layer.borderWidth = 0.5
        ColorSample.backgroundColor = UIColor.white
        contentView.addSubview(ColorSample)
        ColorNameLabel = UILabel(frame: CGRect(x: 110, y: 10, width: 100, height: 30))
        ColorNameLabel.font = UIFont.systemFont(ofSize: 20.0)
        contentView.addSubview(ColorNameLabel)
    }
    
    var ColorNameLabel: UILabel!
    var ColorSample: UIView!
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    public func Initialize(ColorName: String, ColorValue: Int, TableWidth: CGFloat)
    {
        SelectedColor = ColorValue
        let NameLabelWidth = TableWidth - 110 - 5
        ColorNameLabel.frame = CGRect(x: ColorNameLabel.frame.minX,
                                      y: ColorNameLabel.frame.minY,
                                      width: NameLabelWidth,
                                      height: ColorNameLabel.frame.height)
        ColorNameLabel.text = ColorName
        let r: CGFloat = CGFloat((ColorValue & 0xff0000) >> 16)
        let g: CGFloat = CGFloat((ColorValue & 0x00ff00) >> 8)
        let b: CGFloat = CGFloat((ColorValue & 0x0000ff))
        ColorSample.backgroundColor = UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    public var SelectedColor: Int = 0x000000
}
