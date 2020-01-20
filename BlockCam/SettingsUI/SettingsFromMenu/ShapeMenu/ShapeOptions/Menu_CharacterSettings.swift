//
//  Menu_CharacterSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_CharacterSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    let FontPickerTag = 100
    let RangePickerTag = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
        RandomFontSizeSwitch.isOn = Settings.GetBoolean(ForKey: .CharacterRandomFontSize)
        RandomFontSwitch.isOn = Settings.GetBoolean(ForKey: .CharacterUsesRandomFont)
        RangePicker.layer.borderColor = UIColor.black.cgColor
        FontPicker.layer.borderColor = UIColor.black.cgColor
        MakeFontList()
        SetFont()
        let Roughness = Settings.GetString(ForKey: .LetterSmoothness)
        for (Index, Name) in SmoothMap
        {
            if Roughness == Name
            {
                RoughnessPicker.selectedSegmentIndex = Index
                break
            }
        }
        for CharRange in RandomCharacterRanges.allCases
        {
            RangeList.append(CharRange.rawValue)
        }
        RangePicker.reloadAllComponents()
        if let CurrentRange = Settings.GetString(ForKey: .CharacterRandomRange)
        {
            for Index in 0 ..< RangeList.count
            {
                if RangeList[Index] == CurrentRange
                {
                    RangePicker.selectRow(Index, inComponent: 0, animated: true)
                    break
                }
            }
        }
        else
        {
            Settings.SetString(RandomCharacterRanges.AnyCharacter.rawValue, ForKey: .CharacterRandomRange)
            RangePicker.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    var RangeList = [String]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        switch pickerView.tag
        {
            case FontPickerTag:
                return 2
            
            case RangePickerTag:
                return 1
            
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag
        {
            case FontPickerTag:
                return component == 0 ? FontList.count : FontList[SelectedFont].Weights.count
            
            case RangePickerTag:
                return RangeList.count
            
            default:
                break
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let Label = UILabel()
        switch pickerView.tag
        {
            case FontPickerTag:
                let Text = component == 0 ? FontList[row].Family : FontList[SelectedFont].Weights[row]
                Label.font = UIFont.systemFont(ofSize: 17.0)
                Label.text = Text
                Label.textAlignment = .center
            
            case RangePickerTag:
                Label.font = UIFont.systemFont(ofSize: 20.0)
                Label.text = RangeList[row]
                Label.textAlignment = .center
            
            default:
            break
        }
        return Label
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag
        {
            case FontPickerTag:
                return nil
            
            case RangePickerTag:
                return RangeList[row]
            
            default:
                break
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch pickerView.tag
        {
            case FontPickerTag:
                switch component
                {
                    case 0:
                    SelectedFont = row
                    FontPicker.reloadComponent(1)
                    SaveFont(NameIndex: row, WeightIndex: 0)
                    
                    case 1:
                    SelectedWeight = row
                    SaveFont(NameIndex: SelectedFont, WeightIndex: SelectedWeight)
                    
                    default:
                    break
            }
            
            case RangePickerTag:
                Menu_ChangeManager.AddChanged(.CharacterRandomRange)
                Settings.SetString(RangeList[row], ForKey: .CharacterRandomRange)
            
            default:
            break
        }
    }
    
    @IBAction func HandleRandomFontSwitchChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.CharacterUsesRandomFont)
            Settings.SetBoolean(Switch.isOn, ForKey: .CharacterUsesRandomFont)
        }
    }
    
    @IBAction func HandleRoughnessChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
        Menu_ChangeManager.AddChanged(.LetterSmoothness)
        if let SmoothValue = SmoothMap[Segment.selectedSegmentIndex]
        {
            Settings.SetString(SmoothValue, ForKey: .LetterSmoothness)
        }
        else
        {
            Settings.SetString("Medium", ForKey: .LetterSmoothness)
        }
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
    
    @IBAction func HandleRandomFontSizeChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Menu_ChangeManager.AddChanged(.CharacterRandomFontSize)
            Settings.SetBoolean(Switch.isOn, ForKey: .CharacterRandomFontSize)
        }
    }
    
    @IBAction func HandleFontSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            Menu_ChangeManager.AddChanged(.FontSize)
            let Index = Segment.selectedSegmentIndex
            for (FontSize, FontIndex) in FontSizeMap
            {
                if FontIndex == Index
                {
                    Settings.SetInteger(FontSize, ForKey: .FontSize)
                    return
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
    
    @IBAction func HandleCharLocationChanged(_ sender: Any)
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
    
    // MARK: - Font handling functions.
    
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
        }
        else
        {
            Settings.SetString("Avenir-Regular", ForKey: .LetterFont)
            Family = "Avenir"
            Style = "Regular"
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
    
    var SelectedFont: Int = 0
    var SelectedWeight: Int = 0
    
    func SaveFont(NameIndex: Int, WeightIndex: Int)
    {
        Menu_ChangeManager.AddChanged(.LetterFont)
        let SaveMe = FontList[NameIndex].Family + "-" + FontList[NameIndex].Weights[WeightIndex]
        Log.Message("New font: \(SaveMe)")
        Settings.SetString(SaveMe, ForKey: .LetterFont)
    }
    
    typealias FontData = (Family: String, Weights: [String], PSNames: [String])
    
    var FontList: [FontData] = []
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var LetterLocationSelector: UISegmentedControl!
    @IBOutlet weak var FontSizeSegment: UISegmentedControl!
    @IBOutlet weak var RandomFontSizeSwitch: UISwitch!
    @IBOutlet weak var RoughnessPicker: UISegmentedControl!
    @IBOutlet weak var RangePicker: UIPickerView!
    @IBOutlet weak var FontPicker: UIPickerView!
    @IBOutlet weak var RandomFontSwitch: UISwitch!
}

enum RandomCharacterRanges: String, CaseIterable
{
    case AnyCharacter = "Any character in font"
    case Latin = "Latin Characters"
    case Greek = "Greek Characters"
    case Cyrillic = "Cyrillic Characters"
    case CJK = "East Asian Characters"
    case Symbols = "Symbols"
}
