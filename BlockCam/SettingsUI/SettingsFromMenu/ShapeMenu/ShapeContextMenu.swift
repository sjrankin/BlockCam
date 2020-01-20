//
//  ShapeContextMenu.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension Menu_CompositeShapeTableViewCell: UIContextMenuInteractionDelegate
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
    
    /// Make the shape menu for the shape-varying UI.
    func MakeShapeMenu() -> UIMenu
    {
        let CancelMenu = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            _ in
        }
                let CancelGroup = UIMenu(title: "", options: .displayInline, children: [CancelMenu])
        let BlockMenu = UIAction(title: "Blocks", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Blocks.rawValue)
        }
        let SphereMenu = UIAction(title: "Spheres", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Spheres.rawValue)
        }
        let TorusMenu = UIAction(title: "Toroids", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Toroids.rawValue)
        }
        let CylindersMenu = UIAction(title: "Cylinders", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Cylinders.rawValue)
        }
        let CapsulesMenu = UIAction(title: "Capsules", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Capsules.rawValue)
        }
        let ConesMenu = UIAction(title: "Cones", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Cones.rawValue)
        }
        let PyramidsMenu = UIAction(title: "Pyramids", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Pyramids.rawValue)
        }
        let StandardGroup = UIMenu(title: "Standard Shapes", children: [BlockMenu, SphereMenu, TorusMenu, CylindersMenu, CapsulesMenu,
                                                                                  ConesMenu, PyramidsMenu, CancelGroup])
        
        let TrianglesMenu = UIAction(title: "Triangles", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Triangles.rawValue)
        }
        let PentagonsMenu = UIAction(title: "Pentagons", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Pentagons.rawValue)
        }
        let HexagonsMenu = UIAction(title: "Hexagons", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Hexagons.rawValue)
        }
        let OctagonsMenu = UIAction(title: "Octagons", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Octagons.rawValue) 
        }
        let StarsMenu = UIAction(title: "Stars", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Stars.rawValue)
        }
        let PolygonGroup = UIMenu(title: "Polygonal Shapes",
                                  children: [TrianglesMenu, PentagonsMenu, HexagonsMenu, OctagonsMenu, StarsMenu, CancelGroup])
        
        let TetrahedronMenu = UIAction(title: "Tetrahedrons", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Tetrahedrons.rawValue)
        }
        let SolidGroup = UIMenu(title: "Geometric Solids", children: [TetrahedronMenu, CancelGroup])
        
        let LettersMenu = UIAction(title: "Letters", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Letters.rawValue)
        }
        let MeshesMenu = UIAction(title: "Meshes", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Meshes.rawValue)
        }
        #if false
        let HueVaryingMenu = UIAction(title: "Vary by Hue", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.HueVarying.rawValue)
        }
        let SatVaryingMenu = UIAction(title: "Vary by Saturation", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.SaturationVarying.rawValue)
        }
        let BriVaryingMenu = UIAction(title: "Vary by Brightness", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.BrightnessVarying.rawValue)
        }
        let ComplexGroup = UIMenu(title: "Complex Shapes",
                                  children: [LettersMenu, MeshesMenu, HueVaryingMenu, SatVaryingMenu, BriVaryingMenu, CancelGroup])
        #else
        let ComplexGroup = UIMenu(title: "Complex Shapes", children: [LettersMenu, MeshesMenu])
        #endif
        
        let LinesMenu = UIAction(title: "Lines", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.Lines.rawValue)
        }
        let CappedLinesMenu = UIAction(title: "Capped Lines", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.CappedLines.rawValue)
        }
        let RadiatingLinesMenu = UIAction(title: "Radiating Lines", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.RadiatingLines.rawValue)
        }
        let RGBMenu = UIAction(title: "RGB", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.CombinedForRGB.rawValue)
        }
        let HSBMenu = UIAction(title: "HSB", image: nil)
        {
            action in
            self.Delegate?.ShapeChanged(At: self.ShapeIndex, NewShape: NodeShapes.CombinedForHSB.rawValue)
        }
        
        let CombinedGroup = UIMenu(title: "Combined Shapes", children: [LinesMenu, CappedLinesMenu, RadiatingLinesMenu,
                                                                                  RGBMenu, HSBMenu, CancelGroup])
        
        return UIMenu(title: "Shapes", children: [StandardGroup, PolygonGroup, SolidGroup, ComplexGroup, CombinedGroup, CancelGroup])
    }
}
