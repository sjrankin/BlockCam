//
//  PrivacySettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PrivacySettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EnableExifSave.isOn = Settings.GetBoolean(ForKey: .AddUserDataToExif)
        UserNameField.text = Settings.GetString(ForKey: .UserName)
        UserCopyrightField.text = Settings.GetString(ForKey: .UserCopyright)
    }
    
    @IBAction func HandleCopyrightChanged(_ sender: Any)
    {
        if let TextBox = sender as? UITextField
        {
            if let Text = TextBox.text
            {
                Settings.SetString(Text, ForKey: .UserCopyright)
                self.view.endEditing(true)
            }
        }
    }
    
    @IBAction func HandleNameChanged(_ sender: Any)
    {
        if let TextBox = sender as? UITextField
        {
            if let Text = TextBox.text
            {
                Settings.SetString(Text, ForKey: .UserName)
                self.view.endEditing(true)
            }
        }
    }
    
    @IBAction func HandleEnableChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            let IsOn = Switch.isOn
            if IsOn
            {
                let Alert = UIAlertController(title: "Confirm",
                                              message: "Please confirm that you want to save your personally identifiable information in your processed images.",
                                              preferredStyle: .alert)
                Alert.addAction(UIAlertAction(title: "Yes", style: .default)
                {
                    _ in
                    Settings.SetBoolean(true, ForKey: .AddUserDataToExif)
                }
                )
                Alert.addAction(UIAlertAction(title: "No", style: .cancel)
                {
                    _ in
                    Switch.setOn(false, animated: true)
                })
                self.present(Alert, animated: true)
            }
            else
            {
                Settings.SetBoolean(false, ForKey: .AddUserDataToExif)
            }
        }
    }
    
    @IBOutlet weak var UserNameField: UITextField!
    @IBOutlet weak var UserCopyrightField: UITextField!
    @IBOutlet weak var EnableExifSave: UISwitch!
}
