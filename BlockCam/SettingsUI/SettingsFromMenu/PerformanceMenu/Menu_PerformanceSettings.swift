//
//  Menu_PerformanceSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Menu_PerformanceSettings: UITableViewController, Menu_ImageSizeProtocol
{
    public weak var Delegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Menu_ChangeManager.Clear()
        ShowCurrentImageSize()
    }
    
    let ChangeList: [SettingKeys] =
        [
            .MaxImageDimension
    ]
    
    @IBAction func HandleDoneButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            if Menu_ChangeManager.Contains(self.ChangeList)
            {
                self.Delegate?.ContextMenuSettingsChanged(Menu_ChangeManager.AsArray)
            }
        }
    }
    
    func ChangesFromChild(_ Changed: [SettingKeys])
    {
        if Changed.contains(.MaxImageDimension)
        {
            Menu_ChangeManager.AddChanged(.MaxImageDimension)
            ShowCurrentImageSize()
        }
    }
    
    func ShowCurrentImageSize()
    {
        var Size = Settings.GetInteger(ForKey: .MaxImageDimension)
        if Size <= 2000
        {
            if Size < 512
            {
                Size = 512
                Settings.SetInteger(Size, ForKey: .MaxImageDimension)
            }
            CurrentSizeLabel.text = "Resize to \(Size)"
        }
        else
        {
            CurrentSizeLabel.text = "Not resized"
        }
    }
    
    @IBSegueAction func HandleImageSizeInstantiated(_ coder: NSCoder) -> Menu_ImageSizeSettings?
    {
        let ImageSizer = Menu_ImageSizeSettings(coder: coder)
        ImageSizer?.Delegate = self
        return ImageSizer
    }
    
    @IBOutlet weak var CurrentSizeLabel: UILabel!
}
