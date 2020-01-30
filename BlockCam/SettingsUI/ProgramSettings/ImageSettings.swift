//
//  ImageSettings.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ImageSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var SaveHowRaw = SaveOriginalImageActions.Always.rawValue
        if let Raw = Settings.GetString(ForKey: .SaveOriginalImageAction)
        {
            SaveHowRaw = Raw
        }
        else
        {
            Settings.SetString(SaveHowRaw, ForKey: .SaveOriginalImageAction)
        }
        let Index = SaveOriginalImageActions.allCases.firstIndex(of: SaveOriginalImageActions(rawValue: SaveHowRaw)!)!
        SaveWhenSelector.selectedSegmentIndex = Index
        AutoSaveImageSwitch.isOn = Settings.GetBoolean(ForKey: .AutoSaveProcessedImage)
        #if true
        let Cropping = Settings.GetEnum(ForKey: .CroppedImageBorder, EnumType: CroppingOptions.self, Default: CroppingOptions.None)
        if let Index = CropMap[Cropping]
        {
            CroppingSelector.selectedSegmentIndex = Index
        }
        else
        {
            CroppingSelector.selectedSegmentIndex = 0
        }
        #else
        if let RawCrop = Settings.GetString(ForKey: .CroppedImageBorder)
        {
            if let ActualCropping = CroppingOptions(rawValue: RawCrop)
            {
                if let Index = CropMap[ActualCropping.rawValue]
                {
                    CroppingSelector.selectedSegmentIndex = Index
                }
                else
                {
                    CroppingSelector.selectedSegmentIndex = 0
                    Settings.SetString(CroppingOptions.None.rawValue, ForKey: .CroppedImageBorder)
                }
            }
            else
            {
                CroppingSelector.selectedSegmentIndex = 0
                Settings.SetString(CroppingOptions.None.rawValue, ForKey: .CroppedImageBorder)
            }
        }
        else
        {
            CroppingSelector.selectedSegmentIndex = 0
            Settings.SetString(CroppingOptions.None.rawValue, ForKey: .CroppedImageBorder)
        }
        #endif
    }
    
    #if true
    let CropMap =
        [
            CroppingOptions.None: 0,
            CroppingOptions.Close: 1,
            CroppingOptions.Medium: 2,
            CroppingOptions.Far: 3
    ]
    #else
    let CropMap =
    [
        CroppingOptions.None.rawValue: 0,
        CroppingOptions.Close.rawValue: 1,
        CroppingOptions.Medium.rawValue: 2,
        CroppingOptions.Far.rawValue: 3
    ]
    #endif
    
    let SaveOriginalOptions =
    [
        SaveOriginalImageActions.Always.rawValue,
        SaveOriginalImageActions.WhenProcessedSaved.rawValue,
        SaveOriginalImageActions.Never.rawValue
    ]
    
    @IBAction func HandleWhenSavedChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            Settings.SetString(SaveOriginalOptions[Index], ForKey: .SaveOriginalImageAction)
        }
    }
    
    @IBAction func HandleAutoSaveChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBoolean(Switch.isOn, ForKey: .AutoSaveProcessedImage)
        }
    }
    
    @IBAction func HandleCroppingChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            for (Raw, RawIndex) in CropMap
            {
                if RawIndex == Index
                {
                    #if true
                    Settings.SetEnum(Raw, EnumType: CroppingOptions.self, ForKey: .CroppedImageBorder)
                    #else
                    Settings.SetString(Raw, ForKey: .CroppedImageBorder)
                    #endif
                }
            }
        }
    }
    
    @IBOutlet weak var CroppingSelector: UISegmentedControl!
    @IBOutlet weak var AutoSaveImageSwitch: UISwitch!
    @IBOutlet weak var SaveWhenSelector: UISegmentedControl!
}

/// Defines possible actions related to saving the original image (or video).
enum SaveOriginalImageActions: String, CaseIterable
{
    /// Always save the original image. In this case, the original is saved immediately.
    case Always = "Always"
    /// Save the original image if the user saves a processed image. In this case, the original is saved along with the
    /// processed image.
    case WhenProcessedSaved = "When Processed Saved"
    /// Never save the original image.
    case Never = "Never"
}
