//
//  SoundSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SoundSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        EnableAllSoundsSwitch.isOn = Settings.GetBoolean(ForKey: .EnableUISounds)
        ImageProcessingSoundsSwitch.isOn =  Settings.GetBoolean(ForKey: .EnableImageProcessingSound)
        VideoRecordingSoundsSwitch.isOn = Settings.GetBoolean(ForKey: .EnableVideoRecordingSound)
        ButtonPressSoundsSwitch.isOn = Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        CameraShutterSoundSwitch.isOn = Settings.GetBoolean(ForKey: .EnableShutterSound)
        OptionSelectionSoundSwitch.isOn = Settings.GetBoolean(ForKey: .EnableOptionSelectSounds)
        CrashSoundSwitch.isOn = Settings.GetBoolean(ForKey: .EnableCrashSounds)
        SetUI()
    }
    
    func SetUI()
    {
        let ShowCell = Settings.GetBoolean(ForKey: .EnableUISounds)
        #if false
        ImageProcessingSoundsSwitch.isEnabled = Settings.GetBoolean(ForKey: .EnableUISounds)
        VideoRecordingSoundsSwitch.isEnabled = Settings.GetBoolean(ForKey: .EnableUISounds)
        ButtonPressSoundsSwitch.isEnabled = Settings.GetBoolean(ForKey: .EnableUISounds)
        CameraShutterSoundSwitch.isEnabled = Settings.GetBoolean(ForKey: .EnableUISounds)
        OptionSelectionSoundSwitch.isEnabled = Settings.GetBoolean(ForKey: .EnableUISounds)
        CrashSoundSwitch.isEnabled = Settings.GetBoolean(ForKey: .EnableUISounds)
        #else
        let CellCount = self.tableView.numberOfRows(inSection: 1)
        for Index in 0 ..< CellCount
        {
            if let Cell = self.tableView.cellForRow(at: IndexPath(row: Index, section: 1))
            {
                Cell.transform = CGAffineTransform(translationX: ShowCell ? 0.0 : -self.tableView.bounds.width, y: 0)
                UIView.animate(withDuration: 0.25,
                               delay: 0.075 * Double(Index),
                               options: [.curveEaseInOut],
                               animations:
                    {
                        Cell.transform = CGAffineTransform(translationX: ShowCell ? -self.tableView.bounds.width : 0.0, y: 0)
                })
            }
        }
        #endif
    }
    
    @IBAction func HandleEnableAllSoundsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableUISounds)
            SetUI()
        }
    }
    
    @IBAction func HandleCameraShutterSoundChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableShutterSound)
        }
    }
    
    @IBAction func HandleImageProcessingSoundsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableImageProcessingSound)
        }
    }
    
    @IBAction func HandleVideoRecordingSoundChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableVideoRecordingSound)
        }
    }
    
    @IBAction func HandleButtonPressSoundsChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableButtonPressSounds)
        }
    }
    
    @IBAction func HandleOptionSelectionSoundChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableOptionSelectSounds)
        }
    }
    
    @IBAction func HandleCrashSoundChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .EnableCrashSounds)
        }
    }
    
    @IBOutlet weak var CrashSoundSwitch: UISwitch!
    @IBOutlet weak var OptionSelectionSoundSwitch: UISwitch!
    @IBOutlet weak var ButtonPressSoundsSwitch: UISwitch!
    @IBOutlet weak var VideoRecordingSoundsSwitch: UISwitch!
    @IBOutlet weak var EnableAllSoundsSwitch: UISwitch!
    @IBOutlet weak var CameraShutterSoundSwitch: UISwitch!
    @IBOutlet weak var ImageProcessingSoundsSwitch: UISwitch!
}
