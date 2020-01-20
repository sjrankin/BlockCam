//
//  LetterOptionsCode2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

import UIKit

class LetterOptionsCode2: UITableViewController,
    UIPickerViewDelegate, UIPickerViewDataSource,
    UICollectionViewDelegate, UICollectionViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CharSourcePicker.register(ButtonListItem.self, forCellWithReuseIdentifier: "CharacterSourceCell")
        MakeFontList()
        SetFont()
        MakeCharSources()
        ExtrudeSwitch.isOn = Settings.GetBoolean(ForKey: .FullyExtrudeLetters)
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
    }
    
    // MARK: - Extrusion settings.
    
    @IBAction func HandleExtrusionChanged(_ sender: Any)
    {
        Settings.SetBoolean(ExtrudeSwitch.isOn, ForKey: .FullyExtrudeLetters)
    }
    
    // MARK: - Roughness settings.
    
    @IBAction func HandleLetterRoughnessChanged(_ sender: Any)
    {
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
        let SaveMe = FontList[NameIndex].Family + "-" + FontList[NameIndex].Weights[WeightIndex]
        Log.Message("New font: \(SaveMe)")
        Settings.SetString(SaveMe, ForKey: .LetterFont)
        PostScriptName.text = SaveMe
    }
    
    // MARK: - Unicode block settings.
    
    let CharMap =
    [
        ("Latin", UnicodeRanges.BasicLatin),
        ("Greek", UnicodeRanges.GreekExtended),
        ("Cyrillic", UnicodeRanges.Cyrillic),
        ("Arabic", UnicodeRanges.Arabic),
        ("CJK", UnicodeRanges.CJKUnifiedIdeographs),
        ("Hiragana", UnicodeRanges.Hiragana),
        ("Katakana", UnicodeRanges.Katakana),
        ("Hangul", UnicodeRanges.HangulJamo),
        ("Emoji", UnicodeRanges.Emoticons),
        ("Symbols", UnicodeRanges.MiscellaneousSymbols)
    ]
    
    func GetRangeName(ForName: String) -> UnicodeRanges?
    {
        for (Title, RangeName) in CharMap
        {
            if Title == ForName
            {
                return RangeName
            }
        }
        return nil
    }
    
    func MakeCharSources()
    {
        CharSources.append(ButtonListData(CharMap[0].0, 0, false))
        CharSources.append(ButtonListData(CharMap[1].0, 1, false))
        CharSources.append(ButtonListData(CharMap[2].0, 2, false))
        CharSources.append(ButtonListData(CharMap[3].0, 3, false))
        CharSources.append(ButtonListData(CharMap[4].0, 4, false))
        CharSources.append(ButtonListData(CharMap[5].0, 5, false))
        CharSources.append(ButtonListData(CharMap[6].0, 6, false))
        CharSources.append(ButtonListData(CharMap[7].0, 7, false))
                CharSources.append(ButtonListData(CharMap[8].0, 8, false))
                        CharSources.append(ButtonListData(CharMap[9].0, 9, false))
        var BlockList = [String]()
        if let Blocks = Settings.GetString(ForKey: .RandomCharacterSource)
        {
            let Parts = Blocks.split(separator: ",")
            for Part in Parts
            {
                BlockList.append(String(Part))
            }
        }
        else
        {
            BlockList.append("Latin")
            Settings.SetString(UnicodeRanges.BasicLatin.rawValue, ForKey: .RandomCharacterSource)
        }
        
        var SelectedCount = 0
        for Index in 0 ..< CharSources.count
        {
            let ButtonTitle = CharSources[Index].Title
            if let GroupName = GetRangeName(ForName: ButtonTitle)
            {
                if BlockList.contains(GroupName.rawValue)
                {
                    CharSources[Index].Selected = true
                    SelectedCount = SelectedCount + 1
                }
            }
        }
        if SelectedCount == 0
        {
            CharSources[0].Selected = true
        }

        BlockHolder.layer.borderColor = UIColor.black.cgColor
        CharSourcePicker.reloadData()
    }
    
    var CharSources: [ButtonListData] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return CharSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let Item = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterSourceCell", for: indexPath) as? ButtonListItem
        {
            Item.Load(With: CharSources[indexPath.row])
            return Item
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterSourceCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let SelectedItem = CharSources[indexPath.row]
        var SelectCount = 0
        for ItemData in CharSources
        {
            SelectCount = SelectCount + Int(ItemData.Selected ? 1 : 0)
        }
        if SelectCount <= 1 && SelectedItem.Selected
        {
            //Must always be at least one selected group.
            return
        }
        CharSources[indexPath.row].Selected = !CharSources[indexPath.row].Selected
        var BlockString = ""
        for CharSource in CharSources
        {
            if CharSource.Selected
            {
                let Title = CharSource.Title
                for (BlockTitle, BlockActual) in CharMap
                {
                    if BlockTitle == Title
                    {
                        BlockString.append(BlockActual.rawValue)
                        BlockString.append(",")
                    }
                }
            }
        }
        BlockString.removeLast()
        Settings.SetString(BlockString, ForKey: .RandomCharacterSource)
        CharSourcePicker.reloadData()
    }
    
    @IBAction func HandleFontSizeChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
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
    
    @IBOutlet weak var FontSizeSegment: UISegmentedControl!
    @IBOutlet weak var PostScriptName: UILabel!
    @IBOutlet weak var BlockHolder: UIView!
    @IBOutlet weak var ExtrudeSwitch: UISwitch!
    @IBOutlet weak var LetterRoughnessSegment: UISegmentedControl!
    @IBOutlet weak var FontPicker: UIPickerView!
    @IBOutlet weak var CharSourcePicker: UICollectionView!
}


class ButtonListData
{
    /// Initializer.
    /// - Parameter Title: Title of the button.
    /// - Parameter Tag: Integer tag value.
    /// - Parameter Selected: Selected flag.
    init(_ Title: String, _ Tag: Int, _ Selected: Bool)
    {
        self.Title = Title
        self.Tag = Tag
        self.Selected = Selected
    }
    
    /// Initializer.
    /// - Parameter From: Other `ButtonListData` instance to use to populate this instance.
    /// - Parameter WithSelected: Selected flag.
    init(From: ButtonListData, WithSelected: Bool)
    {
        self.Title = From.Title
        self.Tag = From.Tag
        self.Selected = WithSelected
    }
    
    /// Button title.
    public var Title: String = ""
    /// Integer tag.
    public var Tag: Int = 0
    /// Selected flag.
    public var Selected: Bool = false
}

/// UI item for the button list, derived from `UICollectionViewCell`.
class ButtonListItem: UICollectionViewCell
{
    /// Initializer.
    /// - Parameter frame: The frame of the control.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the UI and UI controls.
    func Initialize()
    {
        let Width = self.frame.width
        let Height = self.frame.height
        Label = UILabel(frame: CGRect(x: 5, y: 5, width: Width - 10, height: Height - 10))
        Label.font = UIFont.boldSystemFont(ofSize: 16.0)
        Label.textColor = UIColor.black
        Label.textAlignment = .center
        Label.contentMode = .center
        Label.text = ""
        Container = UIView(frame: CGRect(x: 0, y: 0, width: Width, height: Height))
        Container.backgroundColor = UIColor.white
        Container.layer.borderColor = UIColor.black.cgColor
        Container.layer.borderWidth = 0.5
        Container.layer.cornerRadius = 5.0
        Container.addSubview(Label)
        self.contentView.addSubview(Container)
    }
    
    var Container: UIView!
    var Label: UILabel!
    
    /// Holds a string tag value.
    public var Tag: Int? = nil
    
    /// Load button information.
    /// - Parameter With: Contains information to display.
    public func Load(With: ButtonListData)
    {
        Label.text = With.Title
        Tag = With.Tag
        Container.backgroundColor = With.Selected ? UIColor.systemYellow : UIColor.white
    }
}
