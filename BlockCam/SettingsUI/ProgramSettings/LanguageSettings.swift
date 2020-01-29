//
//  LanguageSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LanguageSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LanguagePicker.layer.borderColor = UIColor.black.cgColor
        for Language in SupportedLanguages.allCases
        {
            LanguageList.append(Language.rawValue)
        }
        LanguagePicker.reloadAllComponents()
        LanguageInstructions.text = ""
        let SystemLanguageText = NSLocalizedString("SystemLanguageText", comment: "")
        SystemLanguageLabel.text = SystemLanguageText + " " + NSLocale.current.languageCode!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let Label = UILabel()
        Label.text = LanguageList[row]
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            Label.font = UIFont.systemFont(ofSize: 20.0)
        }
        else
        {
            Label.font = UIFont.systemFont(ofSize: 17.0)
        }
        return Label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return LanguageList.count
    }
    
    var LanguageList = [String]()
    
    @IBOutlet weak var SystemLanguageLabel: UILabel!
    @IBOutlet weak var LanguagePicker: UIPickerView!
    @IBOutlet weak var LanguageInstructions: UITextView!
}

enum SupportedLanguages: String, CaseIterable
{
    case English = "English"
    case Japanese = "日本語"
}
