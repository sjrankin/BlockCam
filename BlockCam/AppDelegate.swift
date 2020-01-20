//
//  AppDelegate.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import UIKit
import os.log

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    var StartupShortcut: UIApplicationShortcutItem? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        FileIO.InitializeDirectory()
        Log.Initialize()
        Log.Message("Log initialized.")
        Log.Message(Versioning.MakeVersionBlock())
        Settings.Initialize()
        let StartOf1970 = Date(timeIntervalSince1970: 0)
        let SecondsSince1970 = DateInterval(start: StartOf1970, end: Date())
        print("SecondsSince1970=\(SecondsSince1970.duration)")
        let LastInstantiation = Settings.GetInteger(ForKey: .InstantiationTime)
        if LastInstantiation == 0
        {
            Settings.SetInteger(Int(SecondsSince1970.duration), ForKey: .InstantiationTime)
            Settings.SetBoolean(true, ForKey: .ShowUIHelpPrompts)
            Settings.SetInteger(0, ForKey: .CurrentUIHelpCount)
            print("LastInstantiation initialized to \(Settings.GetInteger(ForKey: .InstantiationTime)), ShowUIHelpPrompts<-true, CurrentUIHelpCount<-0")
        }
        else
        {
            let Delta = Int(SecondsSince1970.duration) - LastInstantiation
            print("LastInstandiation=\(LastInstantiation), Delta seconds=\(Delta)")
            if Delta > Settings.GetInteger(ForKey: .ShowUIHelpIfNotUsedDuration)
            {
                print("Not instantiated for \(Settings.GetInteger(ForKey: .ShowUIHelpIfNotUsedDuration)) seconds - resetting UI help prompts.")
                Settings.SetBoolean(true, ForKey: .ShowUIHelpPrompts)
                Settings.SetInteger(0, ForKey: .CurrentUIHelpCount)
            }
        }
        if let ShortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem
        {
            os_log(OSLogType.default, "%@", "Found shortcut item.")
            if ShortcutItem.type == "UpdateAction"
            {
                Settings.Initialize()
                let Alert = UIAlertController(title: "BlockCam", message: "Settings reset to factory values.",
                                              preferredStyle: .alert)
                Alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                window!.rootViewController!.present(Alert, animated: true, completion: nil)
            }
            StartupShortcut = ShortcutItem
        }
        
        return true
    }
    
    /// Alternatively, a shortcut item may be passed in through this delegate method if the app was
    /// still in memory when the Home screen quick action was used. Again, store it for processing.
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void)
    {
        StartupShortcut = shortcutItem
        if shortcutItem.type == "UpdateAction"
        {
            Settings.Initialize()
            let Controller = window!.rootViewController as? ViewController
            Controller?.ShowAlert(Title: "BlockCam", Message: "Settings reset to factory values.", CloseButtonLabel: "OK")
        }
        completionHandler(true)
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
    }
    
    /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was
    /// previously in the background, optionally refresh the user interface. Process any shortcut commands.
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        if let ShortcutItem = StartupShortcut
        {
            if ShortcutItem.type == "UpdateAction"
            {
                #if true
                Settings.Initialize()
                #else
                InitializeSettings()
                #endif
                let Controller = window!.rootViewController as? ViewController
                Controller?.ShowAlert(Title: "BlockCam", Message: "Settings reset to factory values.", CloseButtonLabel: "OK")
            }
            StartupShortcut = nil
        }
    }
}

