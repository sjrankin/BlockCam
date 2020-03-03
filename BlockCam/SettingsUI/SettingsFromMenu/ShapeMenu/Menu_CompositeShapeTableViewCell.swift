//
//  Menu_CompositeShapeTableViewCell.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_CompositeShapeTableViewCell: UITableViewCell
{
    public weak var Delegate: CompositeShapeChangeProtocol? = nil
    
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
            RangeLabel.alpha = super.isEditing ? 0.0 : 1.0
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
        RangeLabel = UILabel(frame: CGRect(x: 110, y: 5, width: 100, height: 35))
        RangeLabel.font = UIFont.systemFont(ofSize: 16.0)
        RangeLabel.textAlignment = .right
        RangeLabel.textColor = UIColor.black
        contentView.addSubview(TitleLabel)
        contentView.addSubview(RangeLabel)
    }
    
    var TitleLabel: UILabel!
    var RangeLabel: UILabel!
    
    func Load(Title: String, RangeString: String, TableWidth: CGFloat, Index: Int)
    {
        /*
        let ItemContextMenu = UIContextMenuInteraction(delegate: self)
        self.addInteraction(ItemContextMenu)
        ShapeIndex = Index
        let TitleWidth = (TableWidth - 10) * 0.6
        let RangePercent = TableWidth - TitleWidth
        TitleLabel.frame = CGRect(x: TitleLabel.frame.minX,
                                  y: TitleLabel.frame.minY,
                                  width: TitleWidth,
                                  height: TitleLabel.frame.height)
        RangeLabel.frame = CGRect(x: TitleWidth + 10,
                                  y: RangeLabel.frame.minY,
                                  width: RangePercent - 20.0,
                                  height: RangeLabel.frame.height)
        TitleLabel.text = Title
        RangeLabel.text = RangeString
        self.selectionStyle = .none
 */
    }
    
    var ShapeIndex = 0
}
