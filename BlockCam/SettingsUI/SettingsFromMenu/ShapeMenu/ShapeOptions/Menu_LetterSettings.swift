//
//  Menu_LetterSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_LetterSettings: UITableViewController,
    UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        FontPicker.layer.borderColor = UIColor.black.cgColor
        MakeFontList()
        SetFont()
        let Roughness = Settings.GetString(ForKey: .LetterSmoothness)
        for (Index, Name) in SmoothMap
        {
            if Roughness == Name
            {
                LetterRoughnessSegment.selectedSegmentIndex = Index
                break
            }
        }
        let FontSize = Settings.GetInteger(ForKey: .FontSize)
        if let Index = FontSizeMap[FontSize]
        {
            FontSizeSegment.selectedSegmentIndex = Index
        }
        else
        {
            FontSizeSegment.selectedSegmentIndex = 1
            Settings.SetInteger(36, ForKey: .FontSize)
        }
        if let CharLocation = Settings.GetString(ForKey: .LetterLocation)
        {
            if let ActualLocation = ShapeLocations(rawValue: CharLocation)
            {
                switch ActualLocation
                {
                    case .Extrude:
                        LetterLocationSelector.selectedSegmentIndex = 0
                    
                    case .Float:
                        LetterLocationSelector.selectedSegmentIndex = 1
                    
                    default:
                    LetterLocationSelector.selectedSegmentIndex = 0
                }
            }
            else
            {
                LetterLocationSelector.selectedSegmentIndex = 0
                Settings.SetString(ShapeLocations.Extrude.rawValue, ForKey: .LetterLocation)
            }
        }
        else
        {
            LetterLocationSelector.selectedSegmentIndex = 0
            Settings.SetString(ShapeLocations.Extrude.rawValue, ForKey: .LetterLocation)
        }
    }
    
    // MARK: - Extrusion settings.
    
    // MARK: - Roughness settings.
    
    @IBAction func HandleLetterRoughnessChanged2(_ sender: Any)
    {
        Menu_ChangeManager.AddChanged(.LetterSmoothness)
        if let SmoothValue = SmoothMap[LetterRoughnessSegment.selectedSegmentIndex]
        {
            Settings.SetString(SmoothValue, ForKey: .LetterSmoothness)
        }
        else
        {
            Settings.SetString("Medium", ForKey: .LetterSmoothness)
        }
    }
    
    let SmoothMap =
        [
            0: "Roughest",
            1: "Rough",
            2: "Medium",
            3: "Smooth",
            4: "Smoothest"
    ]
    
    // MARK: - Font-related settings.
    
    func SetFont()
    {
        var Family = ""
        var Style = ""
        var StoredFont = ""
        if let Stored = Settings.GetString(ForKey: .LetterFont)
        {
            StoredFont = Stored
            let Parts = Stored.split(separator: "-", omittingEmptySubsequences: true)
            if Parts.count == 2
            {
                Family = String(Parts[0])
                Style = String(Parts[1])
            }
            else
            {
                Family = String(Parts[0])
                Style = "Regular"
            }
            PostScriptName.text = Stored
        }
        else
        {
            Settings.SetString("Avenir-Regular", ForKey: .LetterFont)
            Family = "Avenir"
            Style = "Regular"
            PostScriptName.text = "Avenir-Regular"
        }
        if let (FontIndex, WeightIndex) = GetFontIndices(ForName: Family, Weight: Style)
        {
            FontPicker.selectRow(FontIndex, inComponent: 0, animated: true)
            FontPicker.selectRow(WeightIndex, inComponent: 1, animated: true)
        }
        else
        {
            Log.Message("Error deciphering \(StoredFont)")
        }
    }
    
    func GetFontIndices(ForName: String, Weight: String) -> (FontIndex: Int, WeightIndex: Int)?
    {
        var FontIndex = 0
        for FontInfo in FontList
        {
            if FontInfo.Family == ForName
            {
                for WeightIndex in 0 ..< FontInfo.Weights.count
                {
                    if FontInfo.Weights[WeightIndex] == Weight
                    {
                        return (FontIndex: FontIndex, WeightIndex: WeightIndex)
                    }
                }
                return (FontIndex: FontIndex, WeightIndex: 0)
            }
            FontIndex = FontIndex + 1
        }
        return nil
    }
    
    func MakeFontList()
    {
        for Family in UIFont.familyNames
        {
            var Weights = Set<String>()
            let Names = UIFont.fontNames(forFamilyName: Family)
            var LLNames = [String]()
            for Name in Names
            {
                if let Font = UIFont(name: Name, size: 12.0)
                {
                    let FDesc = Font.fontDescriptor
                    LLNames.append(FDesc.postscriptName)
                }
                let Parts = Name.split(separator: "-", omittingEmptySubsequences: true)
                if Parts.count == 1
                {
                    Weights.insert("Regular")
                }
                else
                {
                    Weights.insert(String(Parts.last!))
                }
            }
            let NewData = FontData(Family: Family, Weights: Weights.sorted(), LLNames.sorted())
            FontList.append(NewData)
        }
        FontList.sort{$0.Family < $1.Family}
    }
    
    typealias FontData = (Family: String, Weights: [String], PSNames: [String])
    
    var FontList: [FontData] = []
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0
        {
            return FontList.count
        }
        return FontList[SelectedFont].Weights.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let Text = component == 0 ? FontList[row].Family : FontList[SelectedFont].Weights[row]
        let Label = UILabel()
        Label.font = UIFont.systemFont(ofSize: 17.0)
        Label.text = Text
        Label.textAlignment = .center
        return Label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch component
        {
            case 0:
                SelectedFont = row
                FontPicker.reloadComponent(1)
                SaveFont(NameIndex: row, WeightIndex: 0)
            
            case 1:
                SelectedWeight = row
                SaveFont(NameIndex: SelectedFont, WeightIndex: SelectedWeight)
                #if DEBUG
                let SelectedFamilyIndex = FontPicker.selectedRow(inComponent: 0)
                let FontFamilyData = FontList[SelectedFamilyIndex]
                PostScriptName.text = FontFamilyData.PSNames[row]
            #endif
            
            default:
                break
        }
    }
    
    var SelectedFont: Int = 0
    var SelectedWeight: Int = 0
    
    func SaveFont(NameIndex: Int, WeightIndex: Int)
    {
        Menu_ChangeManager.AddChanged(.LetterFont)
        let SaveMe = FontList[NameIndex].Family + "-" + FontList[NameIndex].Weights[WeightIndex]
        Log.Message("New font: \(SaveMe)")
        Settings.SetString(SaveMe, ForKey: .LetterFont)
        PostScriptName.text = SaveMe
    }
    
    @IBAction func HandleFontSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.FontSize)
            let Index = Segment.selectedSegmentIndex
            for (Size, SizeIndex) in FontSizeMap
            {
                if SizeIndex == Index
                {
                    print("SizeIndex: \(SizeIndex), Size: \(Size)")
                    Settings.SetInteger(Size, ForKey: .FontSize)
                }
            }
        }
    }
    
    let FontSizeMap =
        [
            24: 0,
            36: 1,
            48: 2,
            72: 3,
            144: 4,
            288: 5
    ]
    
    @IBAction func HandleLetterLocationChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.LetterLocation)
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetString(ShapeLocations.Extrude.rawValue, ForKey: .LetterLocation)
                
                case 1:
                Settings.SetString(ShapeLocations.Float.rawValue, ForKey: .LetterLocation)
                
                default:
                Settings.SetString(ShapeLocations.Extrude.rawValue, ForKey: .LetterLocation)
            }
        }
    }
    
    @IBOutlet weak var LetterLocationSelector: UISegmentedControl!
    @IBOutlet weak var FontSizeSegment: UISegmentedControl!
    @IBOutlet weak var PostScriptName: UILabel!
    @IBOutlet weak var LetterRoughnessSegment: UISegmentedControl!
    @IBOutlet weak var FontPicker: UIPickerView!
}
