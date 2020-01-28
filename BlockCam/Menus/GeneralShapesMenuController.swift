//
//  GeneralShapesMenuController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GeneralShapesMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    weak var Delegate: ContextMenuProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapeTable.layer.borderColor = UIColor.black.cgColor
        self.view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        ShapeTable.reloadData()
    }

    var SelectedShape: NodeShapes? = nil
    var HasGroupings = false
    
    public func SetSelectedShape(_ Shape: NodeShapes? = nil)
    {
        SelectedShape = Shape
    }
    
    public func SetTitle(_ NewTitle: String)
    {
        MenuTitle.text = NewTitle
    }
    
    public func LoadShapes(_ List: [NodeShapes])
    {
        HasGroupings = false
        UngroupedShapes = List
    }
    
    var UngroupedShapes = [NodeShapes]()
    
    public func LoadStructuredShapes(_ List: [(GroupName: String, GroupShapes: [NodeShapes])])
    {
        HasGroupings = true
        GroupedShapes = List
    }
    
    var GroupedShapes = [(GroupName: String, GroupShapes: [NodeShapes])]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if HasGroupings
        {
            return GroupedShapes.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if HasGroupings
        {
            return GroupedShapes[section].GroupName
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if HasGroupings
        {
            return GroupedShapes[section].GroupShapes.count
        }
        else
        {
            return UngroupedShapes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if HasGroupings
        {
            let Shape = GroupedShapes[indexPath.section].GroupShapes[indexPath.row]
            let Cell = UITableViewCell(style: .default, reuseIdentifier: "ShapeCell")
            Cell.textLabel?.text = Shape.rawValue
            if let Selected = SelectedShape
            {
                if Selected == Shape
                {
                    Cell.accessoryType = .checkmark
                }
                else
                {
                    Cell.accessoryType = .none
                }
            }
            return Cell
        }
        else
        {
            let Shape = UngroupedShapes[indexPath.row]
            let Cell = UITableViewCell(style: .default, reuseIdentifier: "ShapeCell")
            Cell.textLabel?.text = Shape.rawValue
            if let Selected = SelectedShape
            {
                if Selected == Shape
                {
                    Cell.accessoryType = .checkmark
                }
                else
                {
                    Cell.accessoryType = .none
                }
            }
            return Cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if HasGroupings
        {
            SelectedShape = GroupedShapes[indexPath.section].GroupShapes[indexPath.row]
        }
        else
        {
            SelectedShape = UngroupedShapes[indexPath.row]
        }
        ShapeTable.reloadData()
    }
    
    var WasCancelled = true
    
    @IBAction func HandleOKButton(_ sender: Any)
    {
        WasCancelled = false
        if let Shape = SelectedShape
        {
            self.dismiss(animated: true)
            {
                self.Delegate?.HandleContextMenu(Command: .SelectedNewShape, Parameter: Shape as Any?)
            }
        }
    }
    
    @IBAction func HandleCancelButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if WasCancelled
        {
            Delegate?.HandleContextMenu(Command: .Cancelled, Parameter: nil)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var MenuTitle: UILabel!
    @IBOutlet weak var TitleBox: UIView!
    @IBOutlet weak var ShapeTable: UITableView!
}
