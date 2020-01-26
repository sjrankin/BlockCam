//
//  MenuButton.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class MenuButton: UIButton, UIContextMenuInteractionDelegate
{
    weak var Delegate: MenuButtonProtocol? = nil
        {
        didSet
        {
            CurrentMenu = Delegate?.GetButtonMenu()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    convenience init(SystemImageName: String)
    {
        let Image = UIImage(systemName: SystemImageName)
        self.init()
        self.setImage(Image, for: .normal)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil,
                                          actionProvider:
            {
                suggestedActions in
                return self.CurrentMenu
        }
        )
    }
    
    private var CurrentMenu: UIMenu? = nil
    
    private func SetMenu()
    {
        let ContextMenu = UIContextMenuInteraction(delegate: self)
        self.addInteraction(ContextMenu)
    }
    
    private func OneTimeInitialization()
    {
        if InitializedOnce
        {
            return
        }
        InitializedOnce = true
        //self.addTarget(self, action: #selector(ShowMenu), for: UIControl.Event.touchUpInside)
    }
    
    private var InitializedOnce = false
    
    @objc func ShowMenu()
    {
        if CurrentMenu == nil
        {
            return
        }
    }
    
    private func Initialize()
    {
        OneTimeInitialization()
        self.layer.zPosition = 1000
        if CurrentMenu == nil
        {
            CurrentMenu = Delegate?.GetButtonMenu()
        }
        if _ShowBorder
        {
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 0.5
            self.layer.cornerRadius = 5.0
        }
        else
        {
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0.5
            self.layer.cornerRadius = 5.0
        }
        if !_ImageName.isEmpty
        {
            let Image = UIImage(systemName: _ImageName)
            self.setImage(Image, for: .normal)
        }
        self.tintColor = _ImageColor
    }
    
    private var _ShowBorder: Bool = false
    {
        didSet
        {
            Initialize()
        }
    }
    @IBInspectable public var ShowBorder: Bool
        {
        get
        {
            return _ShowBorder
        }
        set
        {
            _ShowBorder = newValue
        }
    }
    
    private var _ImageColor: UIColor = UIColor.black
    {
        didSet
        {
            Initialize()
        }
    }
    @IBInspectable public var ImageColor: UIColor
        {
        get
        {
            return _ImageColor
        }
        set
        {
            _ImageColor = newValue
        }
    }
    
    private var _PressedImageColor: UIColor = UIColor.black
    @IBInspectable public var PressedImageColor: UIColor
        {
        get
        {
            return _PressedImageColor
        }
        set
        {
            _PressedImageColor = newValue
        }
    }
    
    private var _ImageName: String = ""
    {
        didSet
        {
            Initialize()
        }
    }
    @IBInspectable var ImageName: String
        {
        get
        {
            return _ImageName
        }
        set
        {
            _ImageName = newValue
        }
    }
}
