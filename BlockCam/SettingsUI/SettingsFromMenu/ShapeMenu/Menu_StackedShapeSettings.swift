//
//  Menu_StackedShapeSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_StackedShapeSettings: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UIPopoverPresentationControllerDelegate, ContextMenuProtocol
{
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        StackedShapeTable.layer.borderColor = UIColor.black.cgColor
        if let StackList = Settings.GetString(ForKey: .StackedShapesSet)
        {
            LoadShapeData(FromRaw: StackList)
        }
        else
        {
            Settings.SetString(NodeShapes.Blocks.rawValue, ForKey: .StackedShapesSet)
            LoadShapeData(FromRaw: NodeShapes.Blocks.rawValue)
        }
        StackedShapeTable.reloadData()
        if StackedShapeList.count < 1
        {
            DeleteEverythingButton.isEnabled = false
        }
        else
        {
            DeleteEverythingButton.isEnabled = true
        }
    }
    
    /// Tells the view controller how to display the context menus.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    func LoadShapeData(FromRaw: String)
    {
        StackedShapeList.removeAll()
        if FromRaw.isEmpty
        {
            return
        }
        let Parts = FromRaw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            StackedShapeList.append(String(Part))
        }
    }
    
    var CurrentShape: NodeShapes!
    var StackedShapeList = [String]()
    
    func CreateShapeList() -> String
    {
        var Result = ""
        for Shape in StackedShapeList
        {
            Result.append(Shape)
            Result.append(",")
        }
        return Result
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let Final = CreateShapeList()
        Settings.SetString(Final, ForKey: .StackedShapesSet)
        Menu_ChangeManager.AddChanged(.ShapeType)
        Menu_ChangeManager.AddChanged(.StackedShapesSet)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Menu_CompositeShapeTableViewCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return StackedShapeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = Menu_StackedShapeCell(style: .default, reuseIdentifier: "StackedShapeCell")
        Cell.Load(Title: StackedShapeList[indexPath.row], TableWidth: StackedShapeTable.bounds.size.width, Index: indexPath.row)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            StackedShapeList.remove(at: indexPath.row)
            StackedShapeTable.reloadData()
            DeleteEverythingButton.isEnabled = StackedShapeList.count > 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        StackedShapeList.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        StackedShapeTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let CurrentName = StackedShapeList[indexPath.row]
        let SelectedShape = NodeShapes(rawValue: CurrentName)
        let ListOfShapes = ShapeManager.ValidShapesForStacking()
        SelectedPath = indexPath
        let Cell = tableView.cellForRow(at: indexPath)
        MainDelegate?.RunShapeMenu(SourceView: Cell!, ShapeList: ListOfShapes, Selected: SelectedShape, MenuDelegate: self,
                                   WindowDelegate: self, WindowActual: self)
    }
    
    var SelectedPath: IndexPath? = nil
    
    @IBAction func HandleAddButton(_ sender: Any)
    {
        StackedShapeList.append(NodeShapes.Blocks.rawValue)
        self.DeleteEverythingButton.isEnabled = true
        StackedShapeTable.reloadData()
    }
    
    @IBAction func HandleEditTableButton(_ sender: Any)
    {
        if let Button = sender as? UIBarButtonItem
        {
            StackedShapeTable.setEditing(!StackedShapeTable.isEditing, animated: true)
            if StackedShapeTable.isEditing
            {
                Button.title = "Done"
            }
            else
            {
                Button.title = "Edit"
            }
        }
    }
    
    @IBAction func HandleClearAllShapes(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Confirm", message: "Do you really want to remove all shapes? Will reset list to default value.",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .destructive)
        {
            _ in
            self.StackedShapeList.removeAll()
            self.StackedShapeList.append(NodeShapes.Blocks.rawValue)
            self.StackedShapeTable.reloadData()
            self.DeleteEverythingButton.isEnabled = false
            Settings.SetString(NodeShapes.Blocks.rawValue, ForKey: .StackedShapesSet)
            }
        )
        Alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(Alert, animated: true)
    }

    func HandleContextMenu(Command: ContextMenuCommands)
    {
        fatalError("Shouldn't get here.")
    }
    
    func HandleContextMenu(Command: ContextMenuCommands, Parameter: Any?)
    {
        if Parameter == nil
        {
            return
        }
        switch Command
        {
            case .SelectedNewShape:
                let NewShape = Parameter as! NodeShapes
                StackedShapeList[SelectedPath!.row] = NewShape.rawValue
                StackedShapeTable.reloadData()
            
            default:
                break
        }
    }
    
    @IBOutlet weak var DeleteEverythingButton: UIBarButtonItem!
    @IBOutlet weak var StackedShapeTable: UITableView!
}
