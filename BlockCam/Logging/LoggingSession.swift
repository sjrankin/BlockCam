//
//  LoggingSession.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds information for one logging session.
class LoggingSession
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer
    /// - Parameters:
    ///   - ID: ID of the session.
    ///   - Name: Name of the session (sessions are initially created with no names).
    ///   - TimeStamp: String-encoded time stamp for the session.
    ///   - Device: Name of the device.
    ///   - OSVersion: OS name and version.
    ///   - AppID: ID of the application.
    ///   - AppName: Name of the application.
    ///   - AppVersion: Version of the application.
    ///   - AppBuild: Build of the application
    ///   - AppIsReleased: Application released (eg, not debug) flag.
    init(ID: UUID, Name: String, TimeStamp: String, Device: String, OSVersion: String, AppID: UUID, AppName: String,
         AppVersion: String, AppBuild: Int, AppIsReleased: Bool)
    {
        _ID = ID
        _Name = Name
        _SessionDate = TimeStamp
        _Device = Device
        _OSVersion = OSVersion
        _AppID = AppID
        _AppName = AppName
        _AppVersion = AppVersion
        _AppBuild = AppBuild
        _AppIsReleased = AppIsReleased
    }
    
    /// Holds the name of the session.
    private var _Name: String = ""
    /// Get the name of the session.
    public var Name: String
    {
        get
        {
            return _Name
        }
    }
    
    /// Holds the ID of the session.
    private var _ID: UUID!
    /// Get the ID of the session.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    /// Holds the date of the session.
    private var _SessionDate: String = ""
    /// Get the date of the session as a `String`.
    public var SessionDate: String
    {
        get
        {
            return _SessionDate
        }
    }
    
    /// Return the session date as a `Date`.
    public var ConvertedSessionDate: Date
    {
        get
        {
            return Utilities.StringToDate(_SessionDate)!
        }
    }
    
    /// Holds the type of device.
    private var _Device: String = ""
    /// Get the type of device the program is running on.
    public var Device: String
    {
        get
        {
            return _Device
        }
    }
    
    /// Holds the OS name and version.
    private var _OSVersion: String = ""
    /// Get the OS name and version.
    public var OSVersion: String
    {
        get
        {
            return _OSVersion
        }
    }
    
    /// Holds the App ID.
    private var _AppID: UUID!
    /// Get the app ID.
    public var AppID: UUID
    {
        get
        {
            return _AppID!
        }
    }
    
    /// Holds the App Name.
    private var _AppName: String = ""
    /// Get the app name.
    public var AppName: String
    {
        get
        {
            return _AppName
        }
    }
    
    /// Holds the App Version.
    private var _AppVersion: String = ""
    /// Get the app version.
    public var AppVersion: String
    {
        get
        {
            return _AppVersion
        }
    }
    
    /// Holds the App Build number.
    private var _AppBuild: Int = 0
    /// get the app build number.
    public var AppBuild: Int
    {
        get
        {
            return _AppBuild
        }
    }
    
    /// Holds the app released flag.
    private var _AppIsReleased: Bool = false
    /// Get the app released flag.
    public var AppIsReleased: Bool
    {
        get
        {
            return _AppIsReleased
        }
    }
    
    /// Holds the list of entries for the given log.
    private var _Entries: [LogEntry] = [LogEntry]()
    /// Get or set the list of entries for the log.
    public var Entries: [LogEntry]
    {
        get
        {
            return _Entries
        }
        set
        {
            _Entries = newValue
        }
    }
    
    /// Provided for external use.
    public var ScratchCount: Int = 0
    
    // MARK: - Static functions
    
    /// Return the message entry with the given ID. Child entries are searched as well.
    /// - Parameter Session: The session whose entries will be searched.
    /// - Parameter WithID: The ID to search for.
    /// - Returns: The log entry with the specified ID if found, nil if not found.
    public static func GetEntry(_ Session: LoggingSession, WithID: UUID) -> LogEntry?
    {
        return DoGetEntry(Session.Entries, WithID: WithID)
    }
    
    /// Searches all entries and child entries in the passed array of entries and returns the entry with the specified ID.
    /// - Parameter Entries: The array of entries to search.
    /// - Parameter WithID: The ID to search for.
    /// - Returns: The log entry with the specified ID if found, nil if not found.
    private static func DoGetEntry(_ Entries: [LogEntry], WithID: UUID) -> LogEntry?
    {
        for Entry in Entries
        {
            if Entry.EntryID == WithID
            {
                return Entry
            }
            if Entry.ChildEntries.count > 0
            {
                if let ChildEntry = DoGetEntry(Entry.ChildEntries, WithID: WithID)
                {
                    return ChildEntry
                }
            }
        }
        return nil
    }
    
    // MARK: - Export functions
    
    /// Exports the contents of the logging session as directed.
    /// - Parameter As: Determines the data type of the exported log.
    /// - Returns: The string to export.
    public func Export(As: ExportTypes) -> String
    {
        var Result = ""
        switch As
        {
            case .XML:
                Result = LoggingSession.SessionHeader(From: self, AsType: .XML)
                for Entry in Entries
                {
                    Result.append(Entry.ExportEntry(AsType: .XML, IsLast: false))
                    Result.append("\n")
                }
                Result.append(LoggingSession.SessionFooter(From: self, AsType: .XML))
                return Result
            
            case .JSON:
                var Index = 0
                Result = LoggingSession.SessionHeader(From: self, AsType: .JSON)
                for Entry in Entries
                {
                    let IsLast = Index == Entries.count - 1 ? true : false
                    Result.append(Entry.ExportEntry(AsType: .JSON, IsLast: IsLast))
                    Result.append("\n")
                    Index = Index + 1
                }
                Result.append(LoggingSession.SessionFooter(From: self, AsType: .JSON))
                return Result
            
            default:
                return ""
        }
    }
    
    /// Create a session header for export.
    /// - Parameter From: The logging session whose header will be returned.
    /// - Parameter AsType: Determines the format of the returned header.
    /// - Returns: Header of the session.
    public static func SessionHeader(From: LoggingSession, AsType: ExportTypes) -> String
    {
        var Result = ""
        switch AsType
        {
            case .JSON:
                Result = "{\n"
                Result.append("  \"Session\":\n")
                Result.append("    {\n")
                Result.append("      \"ID\": \"\(From.ID.uuidString)\",\n")
                Result.append("      \"Name\": \"\(From.Name)\",\n")
                Result.append("      \"Date\": \"\(From.SessionDate)\",\n")
                Result.append("      \"Device\":\n")
                Result.append("      {\n")
                Result.append("        \"Name\": \"\(From.Device)\",\n")
                Result.append("        \"OS\": \"\(From.OSVersion)\"\n")
                Result.append("      },\n")
                Result.append("      \"Application\":\n")
                Result.append("      {\n")
                Result.append("        \"Name\": \"\(From.AppName)\",\n")
                Result.append("        \"ID\": \"\(From.AppID.uuidString)\",\n")
                Result.append("        \"Version\": \"\(From.AppVersion)\",\n")
                Result.append("        \"Build\": \"\(From.AppBuild)\",\n")
                Result.append("        \"Released\": \"\(From.AppIsReleased)\"\n")
                Result.append("      }\n")
                Result.append("    },\n")
                Result.append("    \"Entries\":\n")
                Result.append("      [\n")
            
            case .XML:
                Result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                Result.append("<BlockCamLog>\n")
                Result.append("  <Session ID=\"\(From.ID.uuidString)\" Name=\"\(From.Name)\" Date=\"\(From.SessionDate)\">\n")
                Result.append("    <Device Name=\"\(From.Device)\" OS=\"\(From.OSVersion)\"/>\n")
                Result.append("    <Application Name=\"\(From.AppName)\" ID=\"\(From.AppID.uuidString)\" Version=\"\(From.AppVersion)\" Build=\"\(From.AppBuild)\" Released=\"\(From.AppIsReleased)\"/>\n")
                Result.append("    <Entries>\n")
            
            default:
                return ""
        }
        return Result
    }
    
    /// Create a session footer for export.
    /// - Parameter From: The logging session whose footer will be returned.
    /// - Parameter AsType: Determines the formation of the returned footer.
    /// - Returns: Footer of the session.
    public static func SessionFooter(From: LoggingSession, AsType: ExportTypes) -> String
    {
        var Result = ""
        switch AsType
        {
            case .JSON:
                Result.append("      ]\n")
                Result.append("}\n")
            
            case .XML:
                Result.append("    </Entries>\n")
                Result.append("  </Session>\n")
                Result.append("</BlockCamLog>\n")
            
            default:
                return ""
        }
        return Result
    }
}
