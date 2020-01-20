//
//  Menu_CompositeSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_CompositeSettings: UIViewController, UITableViewDelegate, UITableViewDataSource,
    CompositeShapeChangeProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapeTable.layer.borderColor = UIColor.black.cgColor
        if let RawShape = Settings.GetString(ForKey: .ShapeType)
        {
            if let SomeShape = NodeShapes(rawValue: RawShape)
            {
                CurrentShape = SomeShape
            }
            else
            {
                CurrentShape = .HueVarying
            }
        }
        else
        {
            CurrentShape = .HueVarying
        }
        switch CurrentShape
        {
            case .HueVarying:
                self.title = "Composite Hue Shapes"
                ChangedKey = .HueShapeList
                LoadShapeData(FromRaw: Settings.GetString(ForKey: .HueShapeList)!)
            
            case .SaturationVarying:
                self.title = "Composite Saturation Shapes"
                ChangedKey = .SaturationShapeList
                LoadShapeData(FromRaw: Settings.GetString(ForKey: .SaturationShapeList)!)
            
            case .BrightnessVarying:
                self.title = "Composite Brightness Shapes"
                ChangedKey = .BrightnessShapeList
                LoadShapeData(FromRaw: Settings.GetString(ForKey: .BrightnessShapeList)!)
            
            default:
                self.title = "Strange Shapes"
        }
        ShapeTable.reloadData()
        if ShapeList.count < 1
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
        ShapeList.removeAll()
        if FromRaw.isEmpty
        {
            print("No shapes found")
            return
        }
        print("Parsing: \(FromRaw)")
        let Parts = FromRaw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            ShapeList.append(String(Part))
        }
    }
    
    var ChangedKey: SettingKeys!
    var CurrentShape: NodeShapes!
    var ShapeList = [String]()
    
    func CreateShapeList() -> String
    {
        var Result = ""
        for Shape in ShapeList
        {
            Result.append(Shape)
            Result.append(",")
        }
        return Result
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let Final = CreateShapeList()
        Settings.SetString(Final, ForKey: ChangedKey)
        Menu_ChangeManager.AddChanged(.ShapeType)
        Menu_ChangeManager.AddChanged(ChangedKey)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Menu_CompositeShapeTableViewCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ShapeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = Menu_CompositeShapeTableViewCell(style: .default, reuseIdentifier: "CompositeShapeCell")
        var RangeValue = ""
        if ShapeList.count == 1
        {
            RangeValue = "0% to 100%"
        }
        else
        {
            let Percent = 1.0 / Double(ShapeList.count)
            let Start = Percent * Double(indexPath.row)
            let End = Percent * Double(indexPath.row + 1)
            let Multiplier = Settings.GetString(ForKey: .ShapeType) == NodeShapes.HueVarying.rawValue ? 360.0 : 100.0
            let StartString = Utilities.RoundedString(Value: Start * Multiplier, Precision: 2)
            let EndString = Utilities.RoundedString(Value: End * Multiplier, Precision: 2)
            let Mark = Settings.GetString(ForKey: .ShapeType) == NodeShapes.HueVarying.rawValue ? "°" : "%"
            RangeValue = "\(StartString)\(Mark) to \(EndString)\(Mark)"
        }
        Cell.Delegate = self
        Cell.Load(Title: ShapeList[indexPath.row], RangeString: RangeValue, TableWidth: ShapeTable.frame.width, Index: indexPath.row)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            ShapeList.remove(at: indexPath.row)
            DeleteEverythingButton.isEnabled = ShapeList.count > 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        ShapeList.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        ShapeTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    @IBAction func HandleAddButton(_ sender: Any)
    {
        ShapeList.append(NodeShapes.Blocks.rawValue)
        self.DeleteEverythingButton.isEnabled = true
        ShapeTable.reloadData()
    }
    
    @IBAction func HandleEditTableButton(_ sender: Any)
    {
        if let Button = sender as? UIBarButtonItem
        {
            ShapeTable.setEditing(!ShapeTable.isEditing, animated: true)
            if ShapeTable.isEditing
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
        let Alert = UIAlertController(title: "Confirm", message: "Do you really want to remove all shapes?",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .destructive)
        {
            _ in
            self.ShapeList.removeAll()
            self.ShapeTable.reloadData()
            self.DeleteEverythingButton.isEnabled = false
            Settings.SetString("", ForKey: self.ChangedKey)
        }
        )
        Alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(Alert, animated: true)
    }
    
    func ShapeChanged(At Index: Int, NewShape: String)
    {
        ShapeList[Index] = NewShape
        ShapeTable.reloadData()
    }
    
    @IBOutlet weak var DeleteEverythingButton: UIBarButtonItem!
    @IBOutlet weak var ShapeTable: UITableView!
}
