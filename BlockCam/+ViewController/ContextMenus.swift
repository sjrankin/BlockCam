//
//  ContextMenus.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: UIContextMenuInteractionDelegate
{
    /// Handle `contextMenuInteraction`. The menu that is returned depends on the contents of `interaction.view`.
    /// - Parameter interaction: The object that connects to the view that wants the context menu.
    /// - Parameter configurationForMenuAtLocation: Not used.
    /// - Returns: Context menu configuration.
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration?
    {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil,
                                          actionProvider:
            {
                suggestedActions in
                if interaction.view == self.OutputView
                {
                    return self.MakeRenderedSceneMenu()
                }
                else
                {
                    return self.MakeLiveViewMenu()
                }
        })
    }
    
    /// Create the live view context menu.
    /// - Returns: A `UIMenu` for the live view.
    func MakeLiveViewMenu() -> UIMenu
    {
        let ShapesMenu = UIAction(title: "Shape options", image: UIImage(systemName: "square.on.circle"))
        {
            action in
            self.RunShapeSettingsFromMenu()
        }
        let CurrentSettingsMenu = UIAction(title: "Current shape options", image: UIImage(systemName: "slider.horizontal.3"))
        {
            action in
            self.ShowCurrentSettings()
        }
        let ChangeSettingsMenu = UIAction(title: "Change program settings", image: UIImage(systemName: "gear"))
        {
            action in
            self.ChangeSettingsFromMenu()
        }
        
        let PerformanceMenu = UIAction(title: "Performance settings", image: UIImage(systemName: "hare"))
        {
            action in
            self.RunPerformanceSettingsFromMenu()
        }
        let BestPerformance = UIAction(title: "Set best performance", image: UIImage(systemName: "hare.fill"))
        {
            action in
            self.SetForBestPerformance()
        }
        let PerformanceGroup = UIMenu(title: "", options: .displayInline, children: [PerformanceMenu, BestPerformance])
        let DoneMenu = UIAction(title: "Done", image: UIImage(systemName: "xmark.rectangle"))
        {
            _ in
        }
        let DoneGroup = UIMenu(title: "", options: .displayInline, children: [DoneMenu])
        return UIMenu(title: "Options", children: [ShapesMenu, CurrentSettingsMenu, ChangeSettingsMenu, PerformanceGroup, DoneGroup])
    }
    
    /// Create the rendered scene, top-level context menu for 3D scenes.
    /// - Returns: A `UIMenu` for the 3D scene.
    func MakeRenderedSceneMenu() -> UIMenu
    {
        let CancelMenu = UIAction(title: "Cancel", image: UIImage(systemName: "xmark.circle"))
        {
            _ in
        }
        let ShapesMenu = UIAction(title: "Shape options", image: UIImage(systemName: "square.on.circle"))
        {
            action in
            self.RunShapeSettingsFromMenu()
        }
        let LightMenu = UIAction(title: "Lighting options", image: UIImage(systemName: "lightbulb"))
        {
            action in
            self.RunLightingSettingsFromMenu()
        }
        let PerformanceMenu = UIAction(title: "Performance options", image: UIImage(systemName: "hare"))
        {
            action in
            self.RunPerformanceSettingsFromMenu()
        }
        let FullSettingsMenu = UIMenu(title: "", options: .displayInline,
                                      children: [ShapesMenu, /*HeightMenu,*/ LightMenu, PerformanceMenu])
        let ExportMenu = UIAction(title: "Share image", image: UIImage(systemName: "square.and.arrow.up"))
        {
            action in
            self.RunExportProcessedImageFromMenu()
        }
        let ExportGroup = UIMenu(title: "", options: .displayInline, children: [ExportMenu])
        let CurrentSettingsMenu = UIAction(title: "View image settings", image: UIImage(systemName: "slider.horizontal.3"))
        {
            action in
            self.ShowCurrentSettings()
        }
        let LoadSceneMenu = UIAction(title: "Load scene", image: UIImage(systemName: "square.stack.3d.up.fill"))
        {
            action in
            self.LoadSavedScene()
        }
        let SaveSceneMenu = UIAction(title: "Save scene", image: UIImage(systemName: "square.stack.3d.down.right"))
        {
            action in
            self.SaveScene()
        }
        let RecordMenu = UIAction(title: "Record scene", image: UIImage(systemName: "tv"))
        {
            action in
            self.ShowRecordSceneBar()
        }
        let CancelGroup = UIMenu(title: "", options: .displayInline, children: [CancelMenu])
        
        let MainSceneMenu = UIMenu(title: "", options: .displayInline,
                                   children: [LoadSceneMenu, SaveSceneMenu, RecordMenu])
        
        return UIMenu(title: "Options",
                      children: [FullSettingsMenu, ExportGroup, CurrentSettingsMenu, MainSceneMenu, CancelGroup])
    }
}
