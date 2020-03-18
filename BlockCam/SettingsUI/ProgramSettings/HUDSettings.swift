//
//  HUDSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class HUDSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EnableHUDSwitch.isOn = Settings.GetBoolean(ForKey: .EnableHUD)
        ShowSaturationSwitch.isOn = Settings.GetBoolean(ForKey: .ShowSaturation)
        ShowBrightnessSwitch.isOn = Settings.GetBoolean(ForKey: .ShowLightMeter)
        ShowHueSwitch.isOn = Settings.GetBoolean(ForKey: .ShowHue)
        ShowAltitudeSwitch.isOn = Settings.GetBoolean(ForKey: .ShowAltitude)
        ShowCompassSwitch.isOn = Settings.GetBoolean(ForKey: .ShowCompass)
        ShowVersionSwitch.isOn = Settings.GetBoolean(ForKey: .ShowVersionOnHUD)
        ShowMeanColorSwitch.isOn = Settings.GetBoolean(ForKey: .ShowMeanColor)
        ShowHistogramSwitch.isOn = Settings.GetBoolean(ForKey: .ShowHUDHistogram)
    }
    
    @IBAction func HandleEnableHUDChanged(_ sender: Any)
    {
      if let Switch = sender as? UISwitch
      {
        Settings.SetBoolean(Switch.isOn, ForKey: .EnableHUD)
        }
    }
    
    @IBAction func HandleShowBrightnessChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowLightMeter)
        }
    }
    
    @IBAction func HandleShowSaturationChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowSaturation)
        }
    }
    
    @IBAction func HandleShowHueChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowHue)
        }
    }
    
    @IBAction func HandleShowCompassChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowCompass)
        }
    }
    
    @IBAction func HandleShowAltimeterChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowAltitude)
        }
    }
    
    @IBAction func HandleShowVersionChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowVersionOnHUD)
        }
    }
    
    @IBAction func HandleShowMeanColorChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowMeanColor)
        }
    }
    
    @IBAction func HandleShowHistogramChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .ShowHUDHistogram)
        }
    }
    
    @IBOutlet weak var EnableHUDSwitch: UISwitch!
    @IBOutlet weak var ShowSaturationSwitch: UISwitch!
    @IBOutlet weak var ShowBrightnessSwitch: UISwitch!
    @IBOutlet weak var ShowHueSwitch: UISwitch!
    @IBOutlet weak var ShowCompassSwitch: UISwitch!
    @IBOutlet weak var ShowAltitudeSwitch: UISwitch!
    @IBOutlet weak var ShowVersionSwitch: UISwitch!
    @IBOutlet weak var ShowMeanColorSwitch: UISwitch!
    @IBOutlet weak var ShowHistogramSwitch: UISwitch!
}
