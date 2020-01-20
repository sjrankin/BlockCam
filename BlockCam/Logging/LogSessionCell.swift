//
//  LogSessionCell.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LogSessionCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        InitializeUI()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        InitializeUI()
    }
    
    func InitializeUI()
    {
        TitleLabel = UILabel(frame: CGRect(x: 5, y: 1, width: 100, height: 30))
        TitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        contentView.addSubview(TitleLabel)
        SubTitleLabel = UILabel(frame: CGRect(x: 5, y: 25, width: 100, height: 18))
        SubTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
        contentView.addSubview(SubTitleLabel)
        EntryCountLabel = UILabel(frame: CGRect(x: 200, y: 10, width: 50, height: 20))
        EntryCountLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        EntryCountLabel.textColor = UIColor.systemBlue
        EntryCountLabel.textAlignment = .right
        contentView.addSubview(EntryCountLabel)
    }
    
    var TitleLabel: UILabel!
    var SubTitleLabel: UILabel!
    var EntryCountLabel: UILabel!
    
    func LoadData(Title: String, SubTitle: String, Count: Int, Width: CGFloat)
    {
        TitleLabel.frame = CGRect(x: TitleLabel.frame.minX,
                                  y: TitleLabel.frame.minY,
                                  width: Width * 0.75,
                                  height: TitleLabel.frame.height)
        SubTitleLabel.frame = CGRect(x: SubTitleLabel.frame.minX,
                                     y: SubTitleLabel.frame.minY,
                                     width: Width * 0.75,
                                     height: SubTitleLabel.frame.height)
        EntryCountLabel.frame = CGRect(x: Width * 0.77 - 10,
                                       y: EntryCountLabel.frame.minY,
                                       width: Width - (Width * 0.77),
                                       height: EntryCountLabel.frame.height)
        TitleLabel.text = Title
        SubTitleLabel.text = SubTitle
        EntryCountLabel.text = "\(Count)"
    }
}
