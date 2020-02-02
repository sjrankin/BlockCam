//
//  Menu_FavoriteShapesSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_FavoriteShapeSettings: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UIPopoverPresentationControllerDelegate, ContextMenuProtocol
{
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FavoriteShapeTable.layer.borderColor = UIColor.black.cgColor
        if let StackList = Settings.GetString(ForKey: .FavoriteShapeList)
        {
            LoadShapeData(FromRaw: StackList)
        }
        else
        {
            Settings.SetString("", ForKey: .FavoriteShapeList)
            LoadShapeData(FromRaw: "")
        }
        FavoriteShapeTable.reloadData()
        if FavoriteShapeList.count < 1
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
        FavoriteShapeList.removeAll()
        if FromRaw.isEmpty
        {
            return
        }
        let Parts = FromRaw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            FavoriteShapeList.append(String(Part))
        }
    }
    
    var CurrentShape: NodeShapes!
    var FavoriteShapeList = [String]()
    
    func CreateShapeList() -> String
    {
        var Result = ""
        for Shape in FavoriteShapeList
        {
            Result.append(Shape)
            Result.append(",")
        }
        return Result
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let Final = CreateShapeList()
        Settings.SetString(Final, ForKey: .FavoriteShapeList)
        Menu_ChangeManager.AddChanged(.ShapeType)
        Menu_ChangeManager.AddChanged(.FavoriteShapeList)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Menu_StackedShapeCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return FavoriteShapeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = Menu_StackedShapeCell(style: .default, reuseIdentifier: "FavoriteShapeCell")
        Cell.Load(Title: FavoriteShapeList[indexPath.row], TableWidth: FavoriteShapeTable.bounds.size.width,
                  Index: indexPath.row)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            FavoriteShapeList.remove(at: indexPath.row)
            FavoriteShapeTable.reloadData()
            DeleteEverythingButton.isEnabled = FavoriteShapeList.count > 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        FavoriteShapeList.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        FavoriteShapeTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let CurrentName = FavoriteShapeList[indexPath.row]
        let SelectedShape = NodeShapes(rawValue: CurrentName)
        let ListOfShapes = ShapeManager.ShapeFlatList(ExceptFor: FavoriteShapeList)
        SelectedPath = indexPath
        let Cell = tableView.cellForRow(at: indexPath)
        MainDelegate?.RunShapeMenu(SourceView: Cell!, ShapeList: ListOfShapes, Selected: nil,
                                   MenuDelegate: self, WindowDelegate: self, WindowActual: self)
    }
    
    var SelectedPath: IndexPath? = nil
    
    @IBAction func HandleAddButton(_ sender: Any)
    {
        FavoriteShapeList.append(NodeShapes.Blocks.rawValue)
        self.DeleteEverythingButton.isEnabled = true
        FavoriteShapeTable.reloadData()
    }
    
    @IBAction func HandleEditTableButton(_ sender: Any)
    {
        if let Button = sender as? UIBarButtonItem
        {
            FavoriteShapeTable.setEditing(!FavoriteShapeTable.isEditing, animated: true)
            if FavoriteShapeTable.isEditing
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
        let Alert = UIAlertController(title: "Confirm", message: "Do you really want to remove all of your favorite shapes?",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .destructive)
        {
            _ in
            self.FavoriteShapeList.removeAll()
            self.FavoriteShapeTable.reloadData()
            self.DeleteEverythingButton.isEnabled = false
            Settings.SetString("", ForKey: .FavoriteShapeList)
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
                FavoriteShapeList[SelectedPath!.row] = NewShape.rawValue
                FavoriteShapeTable.reloadData()
            
            default:
                break
        }
    }
    
    @IBOutlet weak var DeleteEverythingButton: UIBarButtonItem!
    @IBOutlet weak var FavoriteShapeTable: UITableView!
}
