//
//  Sounds.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

/// Manages sounds. Loads sounds from the system. Plays sounds.
/// - Note: There are two ways to override sounds:
///   1. Muting the device with the mute switch.
///   2. Disabling sounds via user settings.
class Sounds
{
    // MARK: - Initialization.
    
    /// Initialize sounds. If not called, this class will not function properly.
    public static func Initialize()
    {
        GetSoundFiles()
        print("Volume: \(AVAudioSession.sharedInstance().outputVolume)")
    }
    
    //https://github.com/akramhussein/Mute/blob/master/Mute/Classes/Mute.swift
    //https://stackoverflow.com/questions/7255006/get-system-volume-ios
    private static func CheckForHardwareMute() -> Bool
    {
        let Volume = AVAudioSession.sharedInstance().outputVolume
        return Volume == 0.0
    }
    
    /// Holds the most recent result of checking for muted hardware.
    private static var _IsHardwareMuted: Bool = false
    /// Determines if the hardware mute switch is enabled. Checks everytime this property is called.
    public static var IsHardwareMuted: Bool
    {
        get
        {
            _IsHardwareMuted = CheckForHardwareMute()
            return _IsHardwareMuted
        }
    }
    
    // MARK: - Sound file loading.
    
    private static var SoundDirectoryList = ["/Library/Ringtones", "/System/Library/Audio/UISounds"]
    
    private static func GetSoundFiles()
    {
        for Dir in SoundDirectoryList
        {
            let NewDir: NSMutableDictionary =
            [
                "path": Dir,
                "files": []
            ]
            SoundDirectories.append(NewDir)
        }
        GetSoundDirectories(SoundDirectoryList)
        LoadSoundFiles()
        #if false
        for Dir in SoundDirectories
        {
            let soundfiles = Dir.value(forKey: "files") as? [String]
            let dir = Dir.value(forKey: "path") as? String
            print(dir!)
            for file in soundfiles!
            {
                print("  \(file)")
            }
        }
        #endif
    }
    
    private static func LoadSoundFiles()
    {
        for Directory in SoundDirectories
        {
            let DirURL = URL(fileURLWithPath: Directory.value(forKey: "path") as! String, isDirectory: true)
            do
            {
                var URLs: [URL]?
                URLs = try FileManager.default.contentsOfDirectory(at: DirURL,
                                                                   includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
                                                                   options: FileManager.DirectoryEnumerationOptions())
                var IsADirectory: ObjCBool = ObjCBool(false)
                var SoundFiles: [String] = []
                for URL in URLs!
                {
                    FileManager.default.fileExists(atPath: URL.path, isDirectory: &IsADirectory)
                    if !IsADirectory.boolValue
                    {
                        SoundFiles.append(URL.lastPathComponent)
                    }
                }
                Directory["files"] = SoundFiles
            }
            catch
            {
                Log.Message("Error finding sound files in \(DirURL.path): \(error.localizedDescription)")
            }
        }
    }
    
    private static func GetSoundDirectories(_ RootDirectories: [String])
    {
        for Dir in RootDirectories
        {
            let DirURL = URL(fileURLWithPath: Dir, isDirectory: true)
            do
            {
            var URLs: [URL]?
            URLs = try FileManager.default.contentsOfDirectory(at: DirURL,
                                                                   includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
                                                                   options: FileManager.DirectoryEnumerationOptions())
                var URLIsADirectory: ObjCBool = ObjCBool(false)
                for URL in URLs!
                {
                    FileManager.default.fileExists(atPath: URL.path, isDirectory: &URLIsADirectory)
                    if URLIsADirectory.boolValue
                    {
                        let Directory = "\(URL.relativePath)"
                        let NewDir: NSMutableDictionary =
                        [
                            "path": "\(Directory)",
                            "files": []
                        ]
                        SoundDirectories.append(NewDir)
                    }
                }
        }
            catch
            {
                Log.Message("Error searching for \(Dir): \(error.localizedDescription)")
            }
        }
    }
    
    private static var SoundDirectories: [NSMutableDictionary] = []
    
    // MARK - Sound playing.
    
    /// Play the specified sound.
    /// - Parameter ID: The ID of the sound to play.
    public static func PlaySound(_ ID: SoundIDs)
    {
        if IsHardwareMuted
        {
            return
        }
        if Settings.GetBoolean(ForKey: .EnableUISounds)
        {
            let FinalID = UInt32(ID.rawValue)
            AudioServicesPlaySystemSound(FinalID)
        }
    }
    
    /// Play a button-pressed sound.
    public static func ButtonPressSound()
    {
        if IsHardwareMuted
        {
            return
        }
        if Settings.GetBoolean(ForKey: .EnableUISounds)
        {
            let ID = UInt32(SoundIDs.Tock.rawValue)
            AudioServicesPlaySystemSound(ID)
        }
    }
    
    /// Play an alarm sound.
    public static func AlarmSound()
    {
        if IsHardwareMuted
        {
            return
        }
        if Settings.GetBoolean(ForKey: .EnableUISounds)
        {
            let ID = UInt32(SoundIDs.Alarm.rawValue)
            AudioServicesPlaySystemSound(ID)
        }
    }
}

/// Sound IDs for common sounds. Enum values correspond to SDK sound IDs.
enum SoundIDs: Int, CaseIterable
{
    /// Being a long process.
    case Begin = 1110
    /// Complete a long process.
    case Confirm = 1111
    /// Cancel a long process.
    case Cancel = 1112
    /// Begin a video recording.
    case BeginRecording = 1117
    /// End a video recording.
    case EndRecording = 1118
    /// Camera shutter sound.
    case Shutter = 1108
    /// Alarm sound.
    case Alarm = 1304
    /// News flash sound.
    case NewsFlash = 1028
    /// Small tick (tink) sound.
    case Tink = 1103
    /// Small tick (tonk) sound.
    case Tock = 1104
    /// A positive sound.
    case Positive = 1054
    /// A negative sound.
    case Negative = 1053
    /// A beep.
    case Beep = 1052
}
