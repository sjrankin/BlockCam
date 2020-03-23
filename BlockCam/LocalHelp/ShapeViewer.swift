//
//  ShapeViewer.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ShapeViewer: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapeTable.layer.borderColor = UIColor.black.cgColor
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            return 40.0
        }
        else
        {
        return ShapeCell.ShapeCellHeight
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return ShapeManager.ShapeCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return ShapeManager.ShapeCategories[section].CategoryName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ShapeManager.ShapeCategories[section].List.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            let TextCell = UITableViewCell(style: .default, reuseIdentifier: "TextCell")
            let Category = ShapeManager.ShapeCategories[indexPath.section].CategoryName
            if let Description = ShapeManager.CategoryDescription(For: Category)
            {
            TextCell.textLabel?.text = Description
            }
            else
            {
                TextCell.textLabel?.text = "No description found."
            }
            return TextCell
        }
        let Cell = ShapeCell(style: .default, reuseIdentifier: "ShapeCell")
        let RawShape = ShapeManager.ShapeCategories[indexPath.section].List[indexPath.row - 1]
        let NodeShape = NodeShapes(rawValue: RawShape)!
        var ShapeImage = ShapeMap[NodeShape]
        if ShapeImage == nil
        {
            ShapeImage = Generator.ShapeImage(NodeShape)
            ShapeMap[NodeShape] = ShapeImage
        }
        Cell.SetData(Shape: NodeShape, Image: ShapeImage!, TableWidth: ShapeTable.frame.size.width)
        return Cell
    }
    
    var ShapeMap = [NodeShapes: UIImage]()
    
    @IBOutlet weak var ShapeTable: UITableView!
}
