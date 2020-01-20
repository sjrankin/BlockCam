//
//  Menu_CharacterSeries.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/16/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_CharacterSeries: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CharSetPicker.layer.borderColor = UIColor.black.cgColor
        SampleHolder.layer.borderColor = UIColor.black.cgColor
        for Series in ShapeSeries.allCases
        {
            CharSetList.append(Series.rawValue)
        }
        var SavedSeries = ""
        if let SeriesName = Settings.GetString(ForKey: .CharacterSeries)
        {
            SavedSeries = SeriesName
        }
        else
        {
            SavedSeries = ShapeSeries.Flowers.rawValue
            Settings.SetString(SavedSeries, ForKey: .CharacterSeries)
        }
        var Index = 0
        for Name in CharSetList
        {
            if Name == SavedSeries
            {
                CharSetPicker.selectRow(Index, inComponent: 0, animated: true)
                ShowCharacterSet(For: Index)
                break
            }
            Index = Index + 1
        }
    }
    
    var CharSetList = [String]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return CharSetList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return CharSetList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Selected \(CharSetList[row])")
        Settings.SetString(CharSetList[row], ForKey: .CharacterSeries)
        Menu_ChangeManager.AddChanged(.CharacterSeries)
        ShowCharacterSet(For: row)
    }
    
    func ShowCharacterSet(For Index: Int)
    {
        let Raw = CharSetList[Index]
        if let CharSet = ShapeSeries(rawValue: Raw)
        {
            if let CharSetCase = ShapeManager.ShapeMap[CharSet]
            {
                let FontName = ShapeManager.SeriesFontMap[CharSetCase]!
                let SampleFont = UIFont(name: FontName, size: 24.0)!
                var AllChars = CharSetCase.rawValue.replacingOccurrences(of: "\n", with: "")
                AllChars = AllChars.replacingOccurrences(of: " ", with: "")
                let Attributes: [NSAttributedString.Key: Any] =
                    [
                        .font: SampleFont
                ]
                CharSetViewer.attributedText = NSAttributedString(string: AllChars, attributes: Attributes)
            }
        }
    }
    
    @IBOutlet weak var CharSetViewer: UITextView!
    @IBOutlet weak var SampleHolder: UIView!
    @IBOutlet weak var CharSetPicker: UIPickerView!

}
