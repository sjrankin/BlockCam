//
//  LiveViewMenuController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LiveViewMenuController: UIViewController
{
    weak var Delegate: ContextMenuProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        ShapeSettingsBox.layer.borderColor = UIColor.black.cgColor
        ShapeSettingsBox.backgroundColor = UIColor.clear
        ProgramSettingsBox.layer.borderColor = UIColor.black.cgColor
        ProgramSettingsBox.backgroundColor = UIColor.clear
        HelpBox.layer.borderColor = UIColor.black.cgColor
        HelpBox.backgroundColor = UIColor.clear
        FavoriteBox.layer.borderColor = UIColor.black.cgColor
        FavoriteBox.backgroundColor = UIColor.clear
        TitleText.text = "BlockCam " + Versioning.VerySimpleVersionString()
        TitleText.textColor = UIColor.white
        TitleBox.layer.borderColor = UIColor.black.cgColor
        TitleBox.layer.borderWidth = 1.0
        TitleBox.layer.addSublayer(Colors.GetLiveViewTitleBoxGradient(Container: TitleBox.bounds))
    }
    
    var WasCancelled = true
    
    func MakeSound()
    {
        if Settings.GetBoolean(ForKey: .EnableUISounds) && Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
    }
    
    @IBAction func HandleHelpPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .ShowHelp)
        })
    }
    
    @IBAction func HandleProgramSettingsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .ProgramSettings)
        })
    }
    
    @IBAction func HandleCurrentSettingsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .CurrentImageSettings)
        })
    }
    
    @IBAction func HandleImageSettingsPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .SetImageOptions)
        })
    }
    
    @IBAction func HandleAboutButtonPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .ShowAbout)
        })
    }
    
    @IBAction func HandleFavoriteShapesButtonPressed(_ sender: Any)
    {
        MakeSound()
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .ShowFavoriteShapes)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if WasCancelled
        {
            Delegate?.HandleContextMenu(Command: .Cancelled)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var FavoriteBox: UIView!
    @IBOutlet weak var TitleText: UILabel!
    @IBOutlet weak var TitleBox: UIView!
    @IBOutlet weak var HelpBox: UIView!
    @IBOutlet weak var ShapeSettingsBox: UIView!
    @IBOutlet weak var ProgramSettingsBox: UIView!
}
