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
    CompositeShapeChangeProtocol
{
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
    
    func LoadShapeData(FromRaw: String)
    {
        StackedShapeList.removeAll()
        if FromRaw.isEmpty
        {
            print("No shapes found")
            return
        }
        print("Parsing: \(FromRaw)")
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
        Cell.Delegate = self
        return Cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            print("Remove item at \(indexPath.row)")
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
                Button.image = UIImage(systemName: "checkmark.circle")
            }
            else
            {
                Button.image = UIImage(systemName: "square.and.pencil")
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
    
    func ShapeChanged(At Index: Int, NewShape: String)
    {
        StackedShapeList[Index] = NewShape
        StackedShapeTable.reloadData()
    }
    
    @IBOutlet weak var DeleteEverythingButton: UIBarButtonItem!
    @IBOutlet weak var StackedShapeTable: UITableView!
}
