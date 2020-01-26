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
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            let FontSize: CGFloat = 17.0
            AboutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: FontSize)
                        ProgramSettingsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: FontSize)
                        ImageSettingsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: FontSize)
                        CurrentSettingsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: FontSize)
        }
    }
    
    var WasCancelled = true
    
    @IBAction func HandleProgramSettingsPressed(_ sender: Any)
    {
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .ProgramSettings)
        })
    }
    
    @IBAction func HandleCurrentSettingsPressed(_ sender: Any)
    {
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .CurrentImageSettings)
        })
    }
    
    @IBAction func HandleImageSettingsPressed(_ sender: Any)
    {
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .SetImageOptions)
        })
    }
    
    @IBAction func HandleAboutButtonPressed(_ sender: Any)
    {
        WasCancelled = false
        self.dismiss(animated: true, completion:
            {
                self.Delegate?.HandleContextMenu(Command: .ShowAbout)
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
    
    @IBOutlet weak var AboutButton: UIButton!
    @IBOutlet weak var ProgramSettingsButton: UIButton!
    @IBOutlet weak var ImageSettingsButton: UIButton!
    @IBOutlet weak var CurrentSettingsButton: UIButton!
}
