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
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = SettingsButton
                PopView.sourceRect = SettingsButton.bounds
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
    
    /// Show a context menu with a list of shapes.
    /// - Parameter From: The source object the user touched to invoke the menu. Use to make sure the pop-over
    ///                   controller points to the proper UI element.
    /// - Parameter ShapeList: The list of shapes to display.
    /// - Parameter Selected: Optional selected shape. If nil, no shape is selected on start up.
    /// - Parameter MenuDelegate: The delegate to receive commands from the menu. Provided because
    ///                           the most common caller will not be the main view.
    /// - Parameter WindowDelegate: The delegate responsible to act as the window for the popover.
    /// - Parameter WindowActual: The view controller that will present the menu.
    func ShowShapeSelectionMenu(From SourceView: UIView, ShapeList: [NodeShapes], Selected: NodeShapes? = nil,
                                MenuDelegate: ContextMenuProtocol,
                                WindowDelegate: UIPopoverPresentationControllerDelegate,
                                WindowActual: UIViewController)
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "ShapeSelectionMenuUI") as? GeneralShapesMenuController
        {
            Controller.Delegate = MenuDelegate
            Controller.preferredContentSize = CGSize(width: 280.0, height: 530.0)
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = WindowDelegate//self
            }
            Controller.SetSelectedShape(Selected)
            Controller.LoadShapes(ShapeList)
            
            WindowActual.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = SourceView
                PopView.sourceRect = SourceView.bounds
            }
        }
    }
    
    /// Show a context menu with a structured list of shapes.
    /// - Parameter From: The source object the user touched to invoke the menu. Use to make sure the pop-over
    ///                   controller points to the proper UI element.
    /// - Parameter ShapeList: Structured list of shapes.
    /// - Parameter Selected: Optional selected shape. If nil, no shape is selected on start up.
    /// - Parameter MenuDelegate: The delegate to receive commands from the menu. Provided because
    ///                           the most common caller will not be the main view.
    /// - Parameter WindowDelegate: The delegate responsible to act as the window for the popover.
    /// - Parameter WindowActual: The view controller that will present the menu.
    func ShowShapeSelectionMenu(From SourceView: UIView, ShapeList: [(GroupName: String, GroupShapes: [NodeShapes])],
                                Selected: NodeShapes? = nil, MenuDelegate: ContextMenuProtocol,
                                WindowDelegate: UIPopoverPresentationControllerDelegate,
                                WindowActual: UIViewController)
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "ShapeSelectionMenuUI") as? GeneralShapesMenuController
        {
            Controller.Delegate = MenuDelegate
            Controller.preferredContentSize = CGSize(width: 280.0, height: 530.0)
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            Controller.SetSelectedShape(Selected)
            Controller.LoadStructuredShapes(ShapeList)
            WindowActual.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = SourceView
                PopView.sourceRect = SourceView.bounds
            }
        }
    }
}

