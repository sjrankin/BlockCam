//
//  StackedShapeContextMenu.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension Menu_StackedShapeCell: UIContextMenuInteractionDelegate
{
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil,
                                          actionProvider:
            {
                suggestedActions in
                return self.MakeShapeMenu()
        }
        )
    }
    
    /// Make the shape menu for the shape-varying UI. Unfortunately, there seems to be an obscure bug
    /// somewhere in UIMenu that won't let me add items dynamically, hence the unrolled loop.
    func MakeShapeMenu() -> UIMenu
    {
        let CancelMenu = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            _ in
        }
        let CancelGroup = UIMenu(title: "", options: .displayInline, children: [CancelMenu])
        let ValidShapes = ShapeManager.ValidShapesForStacking()
        
        let Menu0 = UIAction(title: ValidShapes[0].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[0].rawValue)
        }
        let Menu1 = UIAction(title: ValidShapes[1].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[1].rawValue)
        }
        let Menu2 = UIAction(title: ValidShapes[2].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[2].rawValue)
        }
        let Menu3 = UIAction(title: ValidShapes[3].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[3].rawValue)
        }
        let Menu4 = UIAction(title: ValidShapes[4].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[4].rawValue)
        }
        let Menu5 = UIAction(title: ValidShapes[5].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[5].rawValue)
        }
        let Menu6 = UIAction(title: ValidShapes[6].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[6].rawValue)
        }
        let Menu7 = UIAction(title: ValidShapes[7].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[7].rawValue)
        }
        let Menu8 = UIAction(title: ValidShapes[8].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[8].rawValue)
        }
        let Menu9 = UIAction(title: ValidShapes[9].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[9].rawValue)
        }
        let Menu10 = UIAction(title: ValidShapes[10].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[10].rawValue)
        }
        let Menu11 = UIAction(title: ValidShapes[11].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[11].rawValue)
        }
        let Menu12 = UIAction(title: ValidShapes[12].rawValue, image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: ValidShapes[12].rawValue)
        }
        
        let ShapeGroup = UIMenu(title: "", options: .displayInline, children: [Menu0, Menu1, Menu2, Menu3, Menu4,
                                                                               Menu5, Menu6, Menu7, Menu8, Menu9,
                                                                               Menu10, Menu11, Menu12])
        return UIMenu(title: "Shapes", children: [ShapeGroup, CancelGroup])
    }
}
