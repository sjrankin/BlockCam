//
//  Menu_ShapeSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_ShapeSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    weak var Delegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Menu_ChangeManager.Clear()
        OptionsButton.isEnabled = false
        var Size = Settings.GetInteger(ForKey: .BlockSize)
        if Size == 0
        {
            Size = 48
            Settings.SetInteger(48, ForKey: .BlockSize)
        }
        if let Index = SizeMap[Size]
        {
            SizeSelector.selectedSegmentIndex = Index
        }
        else
        {
            Settings.SetInteger(48, ForKey: .BlockSize)
            SizeSelector.selectedSegmentIndex = 2
        }
        ShapePicker.layer.borderColor = UIColor.black.cgColor
        ShapePicker.reloadAllComponents()
        if let ShapeName = Settings.GetString(ForKey: .ShapeType)
        {
            if let Shape = NodeShapes(rawValue: ShapeName)
            {
                for (Name, List) in ShapeManager.ShapeCategories
                {
                    if List.contains(Shape.rawValue)
                    {
                        let ShapeIndex = List.firstIndex(of: Shape.rawValue)!
                        let CatIndex = ShapeManager.ShapeCategories.firstIndex(where: {$0.CategoryName == Name})!
                        ShapePicker.selectRow(CatIndex, inComponent: 0, animated: true)
                        SelectedCategory = CatIndex
                        ShapePicker.reloadComponent(1)
                        ShapePicker.selectRow(ShapeIndex, inComponent: 1, animated: true)
                        UpdateOptionButton(Shape)
                    }
                }
            }
        }
    }
    
    func UpdateOptionButton(_ WithShape: NodeShapes)
    {
        let IsInOptionList = ShapeManager.ShapeHasOptions(WithShape)
        OptionsButton.isEnabled = IsInOptionList
    }

    let SizeMap =
        [
            16: 0,
            32: 1,
            48: 2,
            64: 3,
            96: 4,
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        let Count = component == 0 ? ShapeManager.ShapeCategories.count : ShapeManager.ShapeCategories[SelectedCategory].List.count
        return Count
    }
    
    var SelectedCategory = 0
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        #if false
        switch component
        {
            case 0:
                let Label = UILabel()
                Label.text = ShapeManager.ShapeCategories[row].CategoryName
                Label.font = UIFont.boldSystemFont(ofSize: 20.0)
                Label.textAlignment = .center
                return Label
            
            case 1:
                let Decorated = ShapeManager.DecoratedShapeName(From: ShapeManager.ShapeCategories[SelectedCategory].List[row])!
                let Label = UILabel()
                Label.textAlignment = .center
                Label.attributedText = Decorated
                return Label
            
            default:
                return UIView()
        }
        #else
        if component == 1
        {
            let test = ShapeManager.DecoratedShapeName(From: ShapeManager.ShapeCategories[SelectedCategory].List[row])!
            print("\(test.string)")
        }
        let Text = component == 0 ? ShapeManager.ShapeCategories[row].CategoryName : ShapeManager.ShapeCategories[SelectedCategory].List[row]
        let Label = UILabel()
        Label.font = component == 0 ? UIFont.boldSystemFont(ofSize: 20.0) : UIFont.systemFont(ofSize: 20.0)
        Label.text = Text
        Label.textAlignment = .center
        return Label
        #endif
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch component
        {
            case 0:
                SelectedCategory = row
                ShapePicker.reloadComponent(1)
                ShapePicker.selectRow(0, inComponent: 1, animated: true)
                let TopMost = ShapeManager.ShapeCategories[SelectedCategory].List[0]
                let TopShape = NodeShapes(rawValue: TopMost)!
                UpdateOptionButton(TopShape)
                print("Implicitly selected \(TopMost)")
                Settings.SetString(TopMost, ForKey: .ShapeType)
                Menu_ChangeManager.AddChanged(.ShapeType)
            
            case 1:
                let SelectedItem = ShapeManager.ShapeCategories[SelectedCategory].List[row]
                if let NewShape = NodeShapes(rawValue: SelectedItem)
                {
                    Menu_ChangeManager.AddChanged(.ShapeType)
                    Settings.SetString(NewShape.rawValue, ForKey: .ShapeType)
                    UpdateOptionButton(NewShape)
            }
            
            default:
                break
        }
    }
    
    let ChangeList: [SettingKeys] =
        [
            .BlockChamferSize, .CappedLineBallLocation, .StarApexCount, .IncreaseStarApexesWithProminence,
            .LetterLocation, .FontSize, .LetterFont, .LetterSmoothness, .MeshLineThickness, .MeshLineThickness,
            .ShapeType, .BlockSize, .RadiatingLineCount, .RadiatingLineThickness, .ConeIsInverted, .ConeBottomOptions,
            .ConeTopOptions, .HeightSource, .InvertHeight, .VerticalExaggeration, .InvertDynamicColorProcess,
            .DynamicColorAction, .DynamicColorType, .DynamicColorCondition, .SceneBackgroundColor, .SourceAsBackground,
            .CappedLineCapShape, .EllipseShape, .CharacterRandomFontSize, .CharacterFontName, .CharacterRandomRange,
            .CharacterUsesRandomFont, .CharacterSeries, .StackedShapesSet
    ]
    
    @IBAction func HandleDonePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            if Menu_ChangeManager.Contains(self.ChangeList)
            {
                self.Delegate?.Redraw3D(Menu_ChangeManager.AsArray) 
            }
        }
    }
    
    @IBAction func HandleShapeOptionsPressed(_ sender: Any)
    {
        guard let CurrentShape = Settings.GetString(ForKey: .ShapeType) else
        {
            Log.Message("Invalid shape value found in settings.", FileName: #file, FunctionName: #function)
            return
        }
        guard let NodeShape = NodeShapes(rawValue: CurrentShape) else
        {
            Log.Message("Unexpected shape found \(CurrentShape)", FileName: #file, FunctionName: #function)
            return
        }
        if !ShapeManager.ShapeHasOptions(NodeShape)
        {
            return
        }
        switch NodeShape
        {
            case .Blocks:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "BlockSettingsUI") as? Menu_BlockSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .CappedLines:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "CappedLineSettingsUI") as? Menu_CappedLineSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Letters:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "LettersSettingsUI") as? Menu_LetterSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Meshes:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "MeshSettingsUI") as? Menu_MeshSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Stars:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "StarSettingsUI") as? Menu_StarSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .RadiatingLines:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "RadiatingLinesSettingsUI") as? Menu_RadiatingLinesSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Cones:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "ConeLinesSettingsUI") as? Menu_ConeSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .HueVarying, .SaturationVarying, .BrightnessVarying:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "CompositeShapeSettingsUI") as? Menu_CompositeSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Ellipses:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "EllipticalSettingsUI") as? Menu_EllipseSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .StackedShapes:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "StackedShapeSettingsUI") as? Menu_StackedShapeSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .Characters:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "CharacterSettingsUI") as? Menu_CharacterSettings
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            case .CharacterSets:
                let Storyboard = UIStoryboard(name: "Secondary", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(identifier: "CharacterSeriesUI") as? Menu_CharacterSeries
                {
                    self.navigationController?.pushViewController(Controller, animated: true)
            }
            
            default:
                break
        }
    }
    
    @IBAction func HandleSizeSelectorChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.BlockSize)
            let Index = Segment.selectedSegmentIndex
            for (Size, SizeIndex) in SizeMap
            {
                if SizeIndex == Index
                {
                    Settings.SetInteger(Size, ForKey: .BlockSize)
                    break
                }
            }
        }
    }
    
    @IBOutlet weak var SizeSelector: UISegmentedControl!
    @IBOutlet weak var ShapePicker: UIPickerView!
    @IBOutlet weak var OptionsButton: UIButton!
}

