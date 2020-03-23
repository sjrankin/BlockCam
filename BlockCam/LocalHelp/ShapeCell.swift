//
//  ShapeCell.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ShapeCell: UITableViewCell
{
    public static let ShapeCellHeight: CGFloat = 52.0
    
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
        ShapeImage = UIImageView(frame: CGRect(x: 5, y: 2, width: 48, height: 48))
        ShapeImage.contentMode = .scaleAspectFit
        self.contentView.addSubview(ShapeImage)
        ShapeName = UILabel(frame: CGRect(x: 65, y: 15, width: 200, height: 20))
        self.contentView.addSubview(ShapeName)
    }
    
    var ShapeName: UILabel!
    var ShapeImage: UIImageView!
    
    func SetData(Shape: NodeShapes, Image: UIImage, TableWidth: CGFloat)
    {
        let Variable = ShapeManager.MultipleGeometryShapes().contains(Shape) ?
            " (shape varies with color)" : ""
        ShapeName.frame = CGRect(x: ShapeName.frame.origin.x, y: ShapeName.frame.origin.y,
                                 width: TableWidth - 65, height: 20)
        ShapeName.text = Shape.rawValue + Variable
        ShapeImage.image = Image
    }
}
