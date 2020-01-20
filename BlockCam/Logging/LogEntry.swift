//
//  LogEntry.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds information for one log entry.
class LogEntry
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - SessionID: ID of the session this entry belongs to.
    ///   - EntryID: ID of this individual entry.
    ///   - Message: Text message to log.
    ///   - TimeStamp: Time stamp of the entry.
    ///   - Aborted: Aborted flag. True indicates a fatal error was logged.
    init(SessionID: UUID, EntryID: UUID, Message: String, TimeStamp: String, Aborted: Bool = false)
    {
        _SessionID = SessionID
        _EntryID = EntryID
        _Message = Message
        _TimeStamp = TimeStamp
        _Aborted = Aborted
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - SessionID: ID of the session this entry belongs to.
    ///   - EntryID: ID of this individual entry.
    ///   - Message: Text message to log.
    ///   - TimeStamp: Time stamp of the entry.
    ///   - Aborted: Aborted flag. True indicates a fatal error was logged. Defaults to false.
    ///   - ParentID: The ID of the parent entry. If no parent entry, specify nil. Defaults to nil.
    ///   - FileName: The name of the file.
    ///   - FunctionName: The name of the function.
    ///   - LineNumber: The line number.
    init(SessionID: UUID, EntryID: UUID, Message: String, TimeStamp: String, Aborted: Bool = false,
         ParentID: UUID? = nil, FileName: String, FunctionName: String, LineNumber: Int)
    {
        _SessionID = SessionID
        _EntryID = EntryID
        _Message = Message
        _TimeStamp = TimeStamp
        _Aborted = Aborted
        if let ParentEntryID = ParentID
        {
            _ParentID = ParentEntryID
        }
        else
        {
            _ParentID = UUID.Empty
        }
        _FileName = FileName
        _FunctionName = FunctionName
        _LineNumber = LineNumber
    }
    
    /// Holds the session ID.
    private var _SessionID: UUID!
    /// Get the session ID.
    public var SessionID: UUID
    {
        get
        {
            return _SessionID
        }
    }
    
    /// Holds the entry ID.
    private var _EntryID: UUID!
    /// Get the entry ID.
    public var EntryID: UUID
    {
        get
        {
            return _EntryID
        }
    }
    
    /// Holds the text message.
    private var _Message: String = ""
    /// Get the message for the entry.
    public var Message: String
    {
        get
        {
            return _Message
        }
    }
    
    /// Holds the time stamp.
    private var _TimeStamp: String = ""
    /// Holds the string-encoded time stamp. See `ActualTime` for a decoded version of this value.
    public var TimeStamp: String
    {
        get
        {
            return _TimeStamp
        }
    }
    
    /// Returns a decoded version of `TimeStamp`.
    public var ActualTimeStamp: Date
    {
        return Utilities.StringToDate(_TimeStamp)!
    }
    
    /// Holds the aborted flag.
    private var _Aborted: Bool = false
    /// Get the aborted flag.
    public var Aborted: Bool
    {
        get
        {
            return _Aborted
        }
    }
    
    /// Holds the parent ID.
    private var _ParentID: UUID = UUID.Empty
    /// Get the parent ID. This is the ID of the parent entry. If this value is `UUID.Empty`,
    /// no parent ID was set.
    public var ParentID: UUID
    {
        get
        {
            return _ParentID
        }
    }
    
    /// Holds the file name.
    private var _FileName: String = ""
    /// Get the file name.
    public var FileName: String
    {
        get
        {
            return _FileName
        }
    }
    
    /// Holds the function name.
    private var _FunctionName: String = ""
    /// Get the function name.
    public var FunctionName: String
    {
        get
        {
            return _FunctionName
        }
    }
    
    /// Holds the line number.
    private var _LineNumber: Int = 0
    /// Get the line number. If 0, not set.
    public var LineNumber: Int
    {
        get
        {
            return _LineNumber
        }
    }
    
    /// Holds child messages.
    private var _ChildEntries: [LogEntry] = [LogEntry]()
    /// Get or set child messages.
    /// - Note: To automatically populate child messages from a saved log, `Log.PopulateStructuredMessages`
    ///         must be called. Otherwise, all messages will be returned in linear order.
    public var ChildEntries: [LogEntry]
    {
        get
        {
            return _ChildEntries
        }
        set
        {
            _ChildEntries = newValue
        }
    }
    
    /// Convenience mark value.
    public var Marked: Bool = false
    
    /// Export the entry in the specified type/format.
    /// - Parameter AsType: The type/format to export as.
    /// - Parameter IsLast: Flag that says the entry to export is the last in the list.
    /// - Returns: Formatted data for export.
    public func ExportEntry(AsType: ExportTypes, IsLast: Bool) -> String
    {
        return LogEntry.ExportEntry(Entry: self, AsType: AsType, IndentLevel: 2, IsLast: IsLast)
    }
    
    /// Export the passed entry in the specified type/format.
    /// - Parameter Entry: The entry to export.
    /// - Parameter AsType: The type/format to export as.
    /// - Parameter IndentLevel: How many spaced to indent each line.
    /// - Parameter IsLast: If true, the entry is the last entry to export.
    /// - Returns: Formatted data for export.
    public static func ExportEntry(Entry: LogEntry, AsType: ExportTypes, IndentLevel: Int = 2, IsLast: Bool = false) -> String
    {        var Results = ""
        switch AsType
        {
            case .JSON:
                Results = String.Repeating(" ", Count: IndentLevel) + "{\n"
                Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"ID\": \"\(Entry.EntryID.uuidString)\",\n")
                Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"TimeStamp\": \"\(Entry.TimeStamp)\",\n")
                Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"#text\": \"\(Utilities.ToJSONSafeString(Entry.Message))\"\n")
                if Entry.Aborted
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"Aborted\": \"\(Entry.Aborted)\"\n,")
                }
                if Entry.ParentID != UUID.Empty
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"ParentID\": \"\(Entry.ParentID.uuidString)\"\n,")
                }
                if !Entry.FileName.isEmpty && !Entry.FileName.IsAll(" ")
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"FileName\": \"\(Entry.FileName)\"\n,")
                }
                if !Entry.FunctionName.isEmpty && !Entry.FunctionName.IsAll(" ")
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"FunctionName\": \"\(Entry.FunctionName)\"\n,")
                }
                if Entry.LineNumber > 0
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "\"LineNumber\": \"\(Entry.LineNumber)\"\n,")
                }
                if Entry.ChildEntries.count > 0
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel) + "\"ChildEntries\":\n")
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "[\n")
                    for Child in Entry.ChildEntries
                    {
                        Results.append(LogEntry.ExportEntry(Entry: Child, AsType: .JSON, IndentLevel: IndentLevel + 4))
                    }
                    Results.append(String.Repeating(" ", Count: IndentLevel + 2) + "],\n")
                }
                let Comma = IsLast ? "" : ","
                Results.append(String.Repeating(" ", Count: IndentLevel) + "}\(Comma)\n")
            
            case .XML:
                Results = String.Repeating(" ", Count: IndentLevel) + "<Entry ID=\"\(Entry.EntryID.uuidString)\" TimeStamp=\"\(Entry.TimeStamp)\""
                if Entry.Aborted
                {
                    Results.append(" Aborted=\"true\"")
                }
                if Entry.ParentID != UUID.Empty
                {
                    Results.append(" ParentID=\"\(Entry.ParentID.uuidString)\"")
                }
                if !Entry.FileName.isEmpty && !Entry.FileName.IsAll(" ")
                {
                    Results.append(" File=\"\(Entry.FileName)\"")
                }
                if !Entry.FunctionName.isEmpty && !Entry.FunctionName.IsAll(" ")
                {
                    Results.append(" Function=\"\(Entry.FunctionName)\"")
                }
                if Entry.LineNumber > 0
                {
                    Results.append(" Line=\"\(Entry.LineNumber)\"")
                }
                Results.append(">\n")
                if Entry.ChildEntries.count > 0
                {
                    Results.append(String.Repeating(" ", Count: IndentLevel) + "<ChildEntries>\n")
                    for Child in Entry.ChildEntries
                    {
                        Results.append(LogEntry.ExportEntry(Entry: Child, AsType: .XML, IndentLevel: IndentLevel + 2))
                    }
                    Results.append(String.Repeating(" ", Count: IndentLevel) + "</ChildEntries>\n")
                }
                Results.append(String.Repeating(" ", Count: IndentLevel) + Utilities.ToXMLSafeString(Entry.Message) + "\n")
                Results.append(String.Repeating(" ", Count: IndentLevel) + "</Entry>")
            
            default:
                break
        }
        return Results
        
    }
}
