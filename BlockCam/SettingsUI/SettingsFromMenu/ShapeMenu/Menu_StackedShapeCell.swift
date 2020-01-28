//
//  Menu_StackedShapeCell.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_StackedShapeCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 45.0
    
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
    
    override var isEditing: Bool
        {
        get
        {
            return super.isEditing
        }
        set
        {
            super.isEditing = newValue
        }
    }
    
    override var showsReorderControl: Bool
        {
        get
        {
            return true
        }
        set
        {
            //Do nothing
        }
    }
    
    func InitializeUI()
    {
        TitleLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 100, height: 35))
        TitleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        TitleLabel.textColor = UIColor.black
        contentView.addSubview(TitleLabel)
    }
    
    var TitleLabel: UILabel!
    
    func Load(Title: String, TableWidth: CGFloat, Index: Int)
    {
        ShapeIndex = Index
        let TitleWidth = (TableWidth - 10) * 0.8
        TitleLabel.frame = CGRect(x: TitleLabel.frame.minX,
                                  y: TitleLabel.frame.minY,
                                  width: TitleWidth,
                                  height: TitleLabel.frame.height)
        TitleLabel.text = Title
        self.selectionStyle = .none
    }
    
    var ShapeIndex = 0
}
