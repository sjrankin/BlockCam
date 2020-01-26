//
//  PopUpMenus.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

// Popu-up menu (eg, hand-rolled context menus) for settings.
extension ViewController: UIPopoverPresentationControllerDelegate
{
    /// Show the live view context menu.
    func ShowLiveViewMenu()
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "MainLiveViewMenuUI") as? LiveViewMenuController
        {
            Controller.Delegate = self
            if UIDevice.current.userInterfaceIdiom == .phone
            {
                Controller.preferredContentSize = CGSize(width: 200, height: 300)
            }
            else
            {
                Controller.preferredContentSize = CGSize(width: 250, height: 500)
            }
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = LiveViewInfoButton
                PopView.sourceRect = LiveViewInfoButton.bounds
            }
        }
    }
    
    /// Tells the view controller how to display the context menus.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    /// Shows the photo album and processed image view context menu.
    /// - Parameter From: The source object the user touched to invoke the menu. Use to make sure the pop-over
    ///                   controller points to the proper UI element.
    func ShowProcessedViewMenu(From SourceView: UIView)
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "ProcessedImageMenuUI") as? ProcessedImageMenuController
        {
            Controller.Delegate = self
            Controller.preferredContentSize = CGSize(width: 280, height: 530)
            Controller.modalPresentationStyle = .popover
            Controller.MainDelegate = self
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = SourceView
                PopView.sourceRect = SourceView.bounds
            }
        }
    }
}
