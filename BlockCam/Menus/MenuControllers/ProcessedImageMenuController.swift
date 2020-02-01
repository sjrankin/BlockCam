//
//  ProcessedImageMenuController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ProcessedImageMenuController: UIViewController
{
    weak var Delegate: ContextMenuProtocol? = nil
    weak var MainDelegate: MainProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        TitleBar.layer.borderColor = UIColor.black.cgColor
        TitleBar.layer.borderWidth = 1.0
        TitleBar.backgroundColor = UIColor.clear
        TitleBar.layer.addSublayer(Colors.GetGradientFor((MainDelegate?.GetCurrentMode())!, Container: TitleBar.bounds))
        if MainDelegate!.GetCurrentMode() == .PhotoLibrary
        {
            TitleText.textColor = UIColor.black
        }
        else
        {
            TitleText.textColor = UIColor.white
        }
        ImageSettingBox.layer.borderColor = UIColor.black.cgColor
        ImageSettingBox.backgroundColor = UIColor.clear
        CurrentSettingBox.layer.borderColor = UIColor.black.cgColor
        CurrentSettingBox.backgroundColor = UIColor.clear
        SceneBox.layer.borderColor = UIColor.black.cgColor
        SceneBox.backgroundColor = UIColor.clear
        ShareBox.layer.borderColor = UIColor.black.cgColor
        ShareBox.backgroundColor = UIColor.clear
        self.preferredContentSize = CGSize(width: 280.0, height: 450.0)
//        OriginalImage.layer.borderColor = UIColor.systemGray6.cgColor
        OriginalImage.backgroundColor = UIColor.clear
        OriginalImage.alpha = 0.0
        SetOriginalImage(MainDelegate?.GetSourceImage())
    }
    
    func SetOriginalImage(_ Image: UIImage?)
    {
        if Image != nil
        {
            self.preferredContentSize = CGSize(width: 280.0, height: 580.0)
            OriginalImage.alpha = 1.0
            OriginalImage.contentMode = .scaleAspectFit
            OriginalImage.image = Image
        }
    }
    
    var WasCancelled = true
    
    func MakeSound()
    {
        if Settings.GetBoolean(ForKey: .EnableUISounds) && Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
    }
    
    @IBAction func HandleCurrentSettingsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .CurrentImageSettings)
        }
    }
    
    @IBAction func HandleImageSettingsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .SetImageOptions)
        }
    }
    
    @IBAction func HandlePerformanceOptionsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .PerformanceOptions)
        }
    }
    
    @IBAction func HandleLightingOptionsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .LightingOptions)
        }
    }
    
    @IBAction func HandleLoadScenePressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .LoadScene)
        }
    }
    
    @IBAction func HandleSaveScenePressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .SaveScene)
        }
    }
    
    @IBAction func HandleRecordScenePressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .RecordScene)
        }
    }
    
    @IBAction func HandleShareImagePressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .ShareImage)
        }
    }
    
    @IBAction func HandleRunProgramSettings(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true)
        {
            self.Delegate?.HandleContextMenu(Command: .ProgramSettings)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if WasCancelled
        {
            Delegate?.HandleContextMenu(Command: .Cancelled)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var TitleBar: UIView!
    @IBOutlet weak var ImageSettingBox: UIView!
    @IBOutlet weak var CurrentSettingBox: UIView!
    @IBOutlet weak var SceneBox: UIView!
    @IBOutlet weak var ShareBox: UIView!
    @IBOutlet weak var OriginalImage: UIImageView!
    @IBOutlet weak var TitleText: UILabel!
}
