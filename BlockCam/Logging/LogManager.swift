//
//  LogManager.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

/// Persistent log storage class. Each instantiation of BlockCam will start a new logging session. All logged messages are
/// attached to the session.
/// - Note: See [Get line number in Swift](https://stackoverflow.com/questions/24103376/is-there-a-way-to-get-line-number-and-function-name-in-swift-language)
/// - Note: This class combines logging functions with database functions since logs are persisted in the local Sqlite database. File I/O is handled
///         by the `FileIO` class.
/// - Note: Logging is controlled by the user. If the user declines to allow logging, most functionality here will be disabled.
class Log
{
    /// Initializes the log.
    public static func Initialize()
    {
        if AlreadyCreated
        {
            fatalError("Logging initialized too many times.")
        }
        CreateSession()
        AlreadyCreated = true
    }
    
    static var AlreadyCreated = false
    
    /// Create the logging session. Update the database.
    private static func CreateSession()
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            _CanLog = false
            return
        }
        LogURL = FileIO.GetLogURL()
        if LogURL == nil
        {
            print("Unable to retrieve app log database URL. Logging disabled.")
            _CanLog = false
            return
        }
        else
        {
            _CanLog = true
        }
        #if true
        //https://stackoverflow.com/questions/51145708/xcode-sqlite3-dylib-illegal-multi-thread-access-to-database-connection
        if sqlite3_open_v2(LogURL!.path, &Handle,
                        SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
        {
            print("Unable to open handle to \(LogURL!.path), \(String(cString: sqlite3_errmsg(Handle)))")
            _CanLog = false
            return
        }
        #else
        if sqlite3_open(LogURL!.path, &Handle) != SQLITE_OK
        {
            print("Unable to open handle to \(LogURL!.path), \(String(cString: sqlite3_errmsg(Handle)))")
            _CanLog = false
            return
        }
        #endif
        
        var Insert = "INSERT INTO Sessions(ID, Date, Device, OSVersion, AppID, AppName, AppVersion, AppIsReleased, AppBuild, Name) Values("
        Insert.append("'\(SessionID.uuidString.uppercased())', ")
        Insert.append("'\(Utilities.DateToString(Date()))', ")
        Insert.append("'\(Platform.NiceModelName())', ")
        Insert.append("'\(Platform.SystemOSName()) \(Platform.OSVersion())', ")
        Insert.append("'\(Versioning.ProgramID.uppercased())', ")
        Insert.append("'\(Versioning.ApplicationName)', ")
        Insert.append("'\(Versioning.MakeVersionString())', ")
        #if DEBUG
        let IsReleased: Int = 0
        #else
        let IsReleased: Int = 1
        #endif
        Insert.append("\(IsReleased), ")
        Insert.append("\(Versioning.Build), ")
        Insert.append("'\(SessionName)'")
        
        Insert.append(")")
        
        var InsertHandle: OpaquePointer? = nil
        if sqlite3_prepare_v2(Handle, Insert, -1, &InsertHandle, nil) == SQLITE_OK
        {
            let Result = sqlite3_step(InsertHandle)
            if Result != SQLITE_DONE
            {
                print("Error running: \(Insert)")
                _CanLog = false
                sqlite3_finalize(InsertHandle)
                return
            }
        }
        sqlite3_finalize(InsertHandle)
    }
    
    /// Update a session's name.
    /// - Parameter SessionID: The ID of the session to update.
    /// - Parameter NewName: The new name for the session.
    public static func UpdateSessionName(_ SessionID: UUID, _ NewName: String)
    {
        let Update = "UPDATE Sessions SET Name = '\(NewName)' WHERE ID = '\(SessionID.uuidString.uppercased())';"
        var UpdateHandle: OpaquePointer? = nil
        if sqlite3_prepare_v2(Handle, Update, -1, &UpdateHandle, nil) == SQLITE_OK
        {
            if sqlite3_step(UpdateHandle) != SQLITE_DONE
            {
                print("Error updating with \(Update)")
            }
        }
        sqlite3_finalize(UpdateHandle)
    }
    
    /// Handle for the logging database.
    private static var Handle: OpaquePointer? = nil
    
    /// Holds the can log flag.
    private static var _CanLog: Bool = false
    /// Get the can log flag. If true, logging is enabled and available. If false, there was an error opening/creating the
    /// logging database and so therefore, logging is not possible.
    public static var CanLog: Bool
    {
        get
        {
            return _CanLog
        }
    }
    
    /// Holds the URL of the logging database.
    private static var LogURL: URL? = nil
    
    /// Holds the ID of the session.
    private static var _SessionID: UUID = UUID()
    /// Get the ID of the session.
    public static var SessionID: UUID
    {
        get
        {
            return _SessionID
        }
    }
    
    /// Holds the name of the session.
    public static var SessionName: String = ""
    
    /// Add a child message to the log. A child message has a logical parent message that can be used to display messages in a
    /// hierarchical structure if desired. (When printing to the debug console, no such structure is used.)
    /// - Parameter Parent: The ID of the parent message. No error checking is done here so it is possible if the caller specifies
    ///                     a non-existent parent, the child message will be orphaned.
    /// - Parameter Message: The message to send to the logging database.
    /// - Parameter ConsoleToo: If true, the message will be sent to the debug console. If false, it will not.
    /// - Parameter FileName: If supplied, the name of the file where this function was called.
    /// - Parameter FunctionName: If supplied, the name of the function where this file was called.
    /// - Parameter LineNumber: If supplied, a line number associated with this call.
    /// - Return: The ID of the message. This can be used for child messages. If `UUID.Empty` is returned, there was an error
    ///           saving the message to the database and any attempt to use the returned UUID for child messages will generated
    ///           an error.
    @discardableResult public static func ChildMessage(Parent: UUID, _ Message: String, ConsoleToo: Bool = true,
                                                       FileName: String? = nil, FunctionName: String? = nil,
                                                       LineNumber: Int? = nil) -> UUID
    {
        if ConsoleToo
        {
            print(Message)
        }
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return UUID.Empty
        }
        
        if !CanLog
        {
            return UUID.Empty
        }
        
        var MessageID = UUID()
        var Insert = "INSERT INTO Entries(SessionID, Message, TimeStamp, EntryID, Aborted, ParentEntry, FileName, FunctionName, LineNumber) Values("
        Insert.append("'\(SessionID.uuidString.uppercased())', ")
        Insert.append("'\(Message.trimmingCharacters(in: .whitespaces))', ")
        Insert.append("'\(Utilities.DateToString(Date()))', ")
        Insert.append("'\(MessageID.uuidString.uppercased())', ")
        Insert.append("0, ")
        Insert.append("'\(Parent.uuidString.uppercased())', ")
        if let SourceFile = FileName
        {
            Insert.append("'\(SourceFile)', ")
        }
        else
        {
            Insert.append("' ', ")
        }
        if let FunctionID = FunctionName
        {
            Insert.append("'\(FunctionID)', ")
        }
        else
        {
            Insert.append("' ', ")
        }
        Insert.append("\(LineNumber == nil ? 0 : LineNumber!)")
        Insert.append(")")
        var InsertHandle: OpaquePointer? = nil
        if sqlite3_prepare_v2(Handle, Insert, -1, &InsertHandle, nil) == SQLITE_OK
        {
            let Result = sqlite3_step(InsertHandle)
            if Result != SQLITE_DONE
            {
                print("Error running: \(Insert)")
                _CanLog = false
                sqlite3_finalize(InsertHandle)
                MessageID = UUID.Empty
            }
        }
        else
        {
            print("Error preparing \(Insert)")
        }
        sqlite3_finalize(InsertHandle)
        return MessageID
    }
    
    /// Send a message to the logging database.
    /// - Parameter Message: The message to send to the logging database.
    /// - Parameter ConsoleToo: If true, the message will be sent to the debug console. If false, it will not.
    /// - Parameter FileName: If supplied, the name of the file where this function was called.
    /// - Parameter FunctionName: If supplied, the name of the function where this file was called.
    /// - Parameter LineNumber: If supplied, a line number associated with this call.
    /// - Return: The ID of the message. This can be used for child messages. If `UUID.Empty` is returned, there was an error
    ///           saving the message to the database and any attempt to use the returned UUID for child messages will generated
    ///           an error.
    @discardableResult public static func Message(_ Message: String, ConsoleToo: Bool = true, FileName: String? = nil,
                                                  FunctionName: String? = nil, LineNumber: Int? = nil) -> UUID
    {
        if ConsoleToo
        {
            print(Message)
        }
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return UUID.Empty
        }
        if !CanLog
        {
            return UUID.Empty
        }
        
        var MessageID = UUID()
        var Insert = "INSERT INTO Entries(SessionID, Message, TimeStamp, EntryID, Aborted, ParentEntry, FileName, FunctionName, LineNumber) Values("
        Insert.append("'\(SessionID.uuidString.uppercased())', ")
        Insert.append("'\(Message.trimmingCharacters(in: .whitespaces))', ")
        Insert.append("'\(Utilities.DateToString(Date()))', ")
        Insert.append("'\(MessageID.uuidString.uppercased())', ")
        Insert.append("0, ")
        Insert.append("'\(UUID.Empty.uuidString)', ")
        if let SourceFile = FileName
        {
            Insert.append("'\(SourceFile)', ")
        }
        else
        {
            Insert.append("' ', ")
        }
        if let FunctionID = FunctionName
        {
            Insert.append("'\(FunctionID)', ")
        }
        else
        {
            Insert.append("' ', ")
        }
        Insert.append("\(LineNumber == nil ? 0 : LineNumber!)")
        Insert.append(")")
        var InsertHandle: OpaquePointer? = nil
        if sqlite3_prepare_v2(Handle, Insert, -1, &InsertHandle, nil) == SQLITE_OK
        {
            let Result = sqlite3_step(InsertHandle)
            if Result != SQLITE_DONE
            {
                print("Error running: \(Insert)")
                _CanLog = false
                sqlite3_finalize(InsertHandle)
                MessageID = UUID.Empty
            }
        }
        else
        {
            print("Error preparing \(Insert)")
        }
        sqlite3_finalize(InsertHandle)
        return MessageID
    }
    
    /// Send an abort message to the logging database.
    /// - Parameter Message: The message to send to the logging database.
    /// - Parameter ConsoleToo: If true, the message will be sent to the debug console. If false, it will not.
    /// - Parameter FileName: If supplied, the name of the file where this function was called.
    /// - Parameter FunctionName: If supplied, the name of the function where this file was called.
    /// - Parameter LineNumber: If supplied, a line number associated with this call.
    /// - Parameter Completed: Completion handler called after the message has been written to the database. If `CanLog` is `false`,
    ///                        the completion handler is still called even though no logging occurs due to initialization errors.
    ///                        The closure has one parameter of type `String` and is a copy of the contents of `Message`. This
    ///                        closure is intended to be where the `fatalError` is called. By calling `fatalError` in the closure,
    ///                        the caller knows the message will be saved to the logging database (however, see discussion of
    ///                        `CanLog` above).
    public static func AbortMessage(_ Message: String, ConsoleToo: Bool = true, FileName: String? = nil,
                                    FunctionName: String? = nil, LineNumber: Int? = nil, Completed: ((String) -> ())? = nil)
    {
        if ConsoleToo
        {
            print(Message)
        }
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            Completed?(Message)
            return
        }
        if !CanLog
        {
            Completed?(Message)
            return
        }
        
        var Insert = "INSERT INTO Entries(SessionID, Message, TimeStamp, EntryID, Aborted, ParentEntry, FileName, FunctionName, LineNumber) Values("
        Insert.append("'\(SessionID.uuidString.uppercased())', ")
        Insert.append("'\(Message.trimmingCharacters(in: .whitespaces))', ")
        Insert.append("'\(Utilities.DateToString(Date()))', ")
        Insert.append("'\(UUID().uuidString.uppercased())', ")
        Insert.append("1, ")
        Insert.append("'\(UUID.Empty.uuidString)', ' ', ' ', 0")
        Insert.append(")")
        var InsertHandle: OpaquePointer? = nil
        if sqlite3_prepare_v2(Handle, Insert, -1, &InsertHandle, nil) == SQLITE_OK
        {
            let Result = sqlite3_step(InsertHandle)
            if Result != SQLITE_DONE
            {
                print("Error running: \(Insert)")
                _CanLog = false
                sqlite3_finalize(InsertHandle)
            }
        }
        else
        {
            print("Error preparing \(Insert)")
        }
        sqlite3_finalize(InsertHandle)
        Completed?(Message)
    }
    
    /// Set up a query in to the database.
    /// - Parameter DB: The handle of the database for the query.
    /// - Parameter Query: The query string.
    /// - Returns: Handle for the query. Valid only for the same database the query was generated for.
    private static func SetupQuery(DB: OpaquePointer?, Query: String) -> OpaquePointer?
    {
        if DB == nil
        {
            return nil
        }
        if Query.isEmpty
        {
            return nil
        }
        var QueryHandle: OpaquePointer? = nil
        if sqlite3_prepare(DB, Query, -1, &QueryHandle, nil) != SQLITE_OK
        {
            LastSQLErrorCode = sqlite3_errcode(DB)
            LastSQLErrorMessage = String(cString: sqlite3_errmsg(DB))
            print("Error preparing query \"\(Query)\": \(LastSQLErrorMessage)")
            return nil
        }
        return QueryHandle
    }
    
    public static var LastSQLErrorCode: Int32 = SQLITE_OK
    public static var LastSQLErrorMessage: String = ""
    
    /// Returns a list of all sessions in the database.
    /// - Returns: Array of session data.
    public static func GetSessionList() -> [LoggingSession]
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return []
        }
        var Results = [LoggingSession]()
        let GetSessions = "SELECT * FROM Sessions"
        let QueryHandle = SetupQuery(DB: Handle, Query: GetSessions)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let SessionColumn = String(cString: sqlite3_column_text(QueryHandle, 1))
            let DateColumn = String(cString: sqlite3_column_text(QueryHandle, 2))
            let DeviceColumn = String(cString: sqlite3_column_text(QueryHandle, 3))
            let OSVerColumn = String(cString: sqlite3_column_text(QueryHandle, 4))
            let AppIDColumn = String(cString: sqlite3_column_text(QueryHandle, 5))
            let AppNameColumn = String(cString: sqlite3_column_text(QueryHandle, 6))
            let AppVerColumn = String(cString: sqlite3_column_text(QueryHandle, 7))
            let AppReleasedColumn = sqlite3_column_int(QueryHandle, 8)
            let AppBuildColumn = sqlite3_column_int(QueryHandle, 9)
            let NameColumn = String(cString: sqlite3_column_text(QueryHandle, 10))
            let Session = LoggingSession(ID: UUID(uuidString: SessionColumn)!,
                                         Name: NameColumn,
                                         TimeStamp: DateColumn,
                                         Device: DeviceColumn,
                                         OSVersion: OSVerColumn,
                                         AppID: UUID(uuidString: AppIDColumn)!,
                                         AppName: AppNameColumn,
                                         AppVersion: AppVerColumn,
                                         AppBuild: Int(AppBuildColumn),
                                         AppIsReleased: AppReleasedColumn != 0 ? true : false)
            Results.append(Session)
        }
        return Results
    }
    
    /// Returns the specified session.
    /// - Parameter ID: ID of the session to return. (IDs can be obtained by calling `GetSessionList`.)
    /// - Returns: A populated `LoggingSession` class on success, nil if not found.
    public static func GetSession(_ ID: UUID) -> LoggingSession?
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return nil
        }
        let SessionID = ID.uuidString.uppercased()
        let GetSession = "SELECT * FROM Sessions WHERE ID='\(SessionID)'"
        let QueryHandle = SetupQuery(DB: Handle, Query: GetSession)
        var FoundSession = false
        var Session: LoggingSession!
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            FoundSession = true
            let SessionColumn = String(cString: sqlite3_column_text(QueryHandle, 1))
            let DateColumn = String(cString: sqlite3_column_text(QueryHandle, 2))
            let DeviceColumn = String(cString: sqlite3_column_text(QueryHandle, 3))
            let OSVerColumn = String(cString: sqlite3_column_text(QueryHandle, 4))
            let AppIDColumn = String(cString: sqlite3_column_text(QueryHandle, 5))
            let AppNameColumn = String(cString: sqlite3_column_text(QueryHandle, 6))
            let AppVerColumn = String(cString: sqlite3_column_text(QueryHandle, 7))
            let AppReleasedColumn = sqlite3_column_int(QueryHandle, 8)
            let AppBuildColumn = sqlite3_column_int(QueryHandle, 9)
            let NameColumn = String(cString: sqlite3_column_text(QueryHandle, 10))
            Session = LoggingSession(ID: UUID(uuidString: SessionColumn)!,
                                     Name: NameColumn,
                                     TimeStamp: DateColumn,
                                     Device: DeviceColumn,
                                     OSVersion: OSVerColumn,
                                     AppID: UUID(uuidString: AppIDColumn)!,
                                     AppName: AppNameColumn,
                                     AppVersion: AppVerColumn,
                                     AppBuild: Int(AppBuildColumn),
                                     AppIsReleased: AppReleasedColumn != 0 ? true : false)
        }
        if !FoundSession
        {
            return nil
        }
        return Session!
    }
    
    /// Returns the number of entries for the specified session.
    /// - Warning: `0` is returned on error as well for sessions with no entries.
    /// - Parameter ForSessionID: The ID of the session whose number of entries will be returned.
    /// - Returns: Number of entries for the given session. Note that `0` is returned on error as well.
    public static func GetEntryCount(ForSessionID: UUID) -> Int
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return 0
        }
        let GetCount = "SELECT COUNT(*) FROM Entries WHERE SessionID='\(ForSessionID.uuidString.uppercased())';"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(Handle, GetCount, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return Int(Count)
            }
        }
        print("Error returned when preparing \(GetCount)")
        return 0
    }
    
    /// Load all entries for the specified session.
    /// - Parameter Session: The session that will be loaded. All entries are stored in the passed session instance.
    public static func PopulateEntries(_ Session: LoggingSession)
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return
        }
        Session.Entries.removeAll()
        let SessionID = Session.ID.uuidString.uppercased()
        let GetEntries = "SELECT * FROM Entries WHERE SessionID='\(SessionID)'"
        let QueryHandle = SetupQuery(DB: Handle, Query: GetEntries)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let EntrySessionColumn = String(cString: sqlite3_column_text(QueryHandle, 1))
            let MessageColumn = String(cString: sqlite3_column_text(QueryHandle, 2))
            let TimeColumn = String(cString: sqlite3_column_text(QueryHandle, 3))
            let EntryIDColumn = String(cString: sqlite3_column_text(QueryHandle, 4))
            let AbortedColumn = sqlite3_column_int(QueryHandle, 5)
            let ParentColumn = String(cString: sqlite3_column_text(QueryHandle, 6))
            let FileColumn = String(cString: sqlite3_column_text(QueryHandle, 7))
            let FunctionColumn = String(cString: sqlite3_column_text(QueryHandle, 8))
            let LineColumn = sqlite3_column_int(QueryHandle, 9)
            let Entry = LogEntry(SessionID: UUID(uuidString: EntrySessionColumn)!,
                                 EntryID: UUID(uuidString: EntryIDColumn)!,
                                 Message: MessageColumn,
                                 TimeStamp: TimeColumn,
                                 Aborted: AbortedColumn != 0 ? true : false,
                                 ParentID: UUID(uuidString: ParentColumn),
                                 FileName: FileColumn,
                                 FunctionName: FunctionColumn,
                                 LineNumber: Int(LineColumn))
            Session.Entries.append(Entry)
        }
    }
    
    /// Populate the passed session with all entries. Child entries will be placed in the appropriate parent entry.
    /// - Parameter Session: The session to populate.
    public static func PopulateStructuredMessages(_ Session: LoggingSession)
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return
        }
        Session.Entries.removeAll()
        let SessionID = Session.ID.uuidString.uppercased()
        let GetEntries = "SELECT * FROM Entries WHERE SessionID='\(SessionID)'"
        let QueryHandle = SetupQuery(DB: Handle, Query: GetEntries)
        var Entries = [LogEntry]()
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let EntrySessionColumn = String(cString: sqlite3_column_text(QueryHandle, 1))
            let MessageColumn = String(cString: sqlite3_column_text(QueryHandle, 2))
            let TimeColumn = String(cString: sqlite3_column_text(QueryHandle, 3))
            let EntryIDColumn = String(cString: sqlite3_column_text(QueryHandle, 4))
            let AbortedColumn = sqlite3_column_int(QueryHandle, 5)
            let ParentColumn = String(cString: sqlite3_column_text(QueryHandle, 6))
            let FileColumn = String(cString: sqlite3_column_text(QueryHandle, 7))
            let FunctionColumn = String(cString: sqlite3_column_text(QueryHandle, 8))
            let LineColumn = sqlite3_column_int(QueryHandle, 9)
            let Entry = LogEntry(SessionID: UUID(uuidString: EntrySessionColumn)!,
                                 EntryID: UUID(uuidString: EntryIDColumn)!,
                                 Message: MessageColumn,
                                 TimeStamp: TimeColumn,
                                 Aborted: AbortedColumn != 0 ? true : false,
                                 ParentID: UUID(uuidString: ParentColumn),
                                 FileName: FileColumn,
                                 FunctionName: FunctionColumn,
                                 LineNumber: Int(LineColumn))
            Entries.append(Entry)
        }
        let TopLevelEntries = Entries.filter{$0.ParentID == UUID.Empty}
        Session.Entries.append(contentsOf: TopLevelEntries)
        var LowerEntries = Entries.filter{$0.ParentID != UUID.Empty}
        if LowerEntries.count > 0
        {
            var MarkedCount = LowerEntries.count
            for Low in LowerEntries
            {
                if !Low.Marked
                {
                    if let Parent = LoggingSession.GetEntry(Session, WithID: Low.ParentID)
                    {
                        Parent.ChildEntries.append(Low)
                        Low.Marked = true
                        MarkedCount = MarkedCount - 1
                    }
                }
            }
            LowerEntries = LowerEntries.filter{!$0.Marked}
            while MarkedCount > 0
            {
                for Low in LowerEntries
                {
                    if !Low.Marked
                    {
                        if let Parent = LoggingSession.GetEntry(Session, WithID: Low.ParentID)
                        {
                            Parent.ChildEntries.append(Low)
                            Low.Marked = true
                            MarkedCount = MarkedCount - 1
                        }
                    }
                }
            }
        }
    }
    
    /// Return a list of entries (regardless of session) that have the aborted flag set.
    /// - Note: The aborted flag is used to indicate fatal error logging messages.
    /// - Returns: Array of entries that have their aborted flag set.
    public static func GetAbortedEntries() -> [LogEntry]
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return []
        }
        let GetAbortedEntries = "SELECT * FROM Entries WHERE Aborted = 1;"
        var Results = [LogEntry]()
        var SearchQuery: OpaquePointer? = nil
        if sqlite3_prepare_v2(Handle, GetAbortedEntries, -1, &SearchQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(SearchQuery) == SQLITE_ROW
            {
                let EntrySessionColumn = String(cString: sqlite3_column_text(SearchQuery, 1))
                let MessageColumn = String(cString: sqlite3_column_text(SearchQuery, 2))
                let TimeColumn = String(cString: sqlite3_column_text(SearchQuery, 3))
                let EntryIDColumn = String(cString: sqlite3_column_text(SearchQuery, 4))
                let AbortedColumn = sqlite3_column_int(SearchQuery, 5)
                let Entry = LogEntry(SessionID: UUID(uuidString: EntrySessionColumn)!,
                                     EntryID: UUID(uuidString: EntryIDColumn)!,
                                     Message: MessageColumn,
                                     TimeStamp: TimeColumn,
                                     Aborted: AbortedColumn != 0 ? true : false)
                Results.append(Entry)
            }
        }
        return Results
    }
    
    /// Determines if a session with the passed ID exists in the Sessions table.
    /// - Parameter ID: The ID to look for.
    /// - Returns: True if a session row was found with the passed ID, false if not.
    public static func SessionExists(_ ID: UUID) -> Bool
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return false
        }
        let CountStatement = "SELECT COUNT(*) FROM Sessions WHERE ID = '\(ID.uuidString.uppercased())';"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(Handle, CountStatement, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return Count > 0 ? true : false
            }
        }
        print("Error returned when preparing \(CountStatement)")
        return false
    }
    
    /// Delete the session with the passed ID.
    /// - Parameter ID: ID of the session to delete.
    /// - Returns: True on success, false on failure. Error message sent to debug console.
    @discardableResult public static func DeleteSession(_ ID: UUID) -> Bool
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return false
        }
        if !SessionExists(ID)
        {
            print("Did not find session with ID \(ID.uuidString)")
            return false
        }
        let DeleteFromSession = "DELETE FROM Sessions WHERE ID = '\(ID.uuidString.uppercased())'"
        var DeletePointer: OpaquePointer? = nil
        var DeletedOK = false
        if sqlite3_prepare_v2(Handle, DeleteFromSession, -1, &DeletePointer, nil) == SQLITE_OK
        {
            if sqlite3_step(DeletePointer) == SQLITE_DONE
            {
                DeletedOK = DeleteEntriesWith(ID: ID)
            }
            else
            {
                print("Error deleting session: \(DeleteFromSession)")
            }
        }
        else
        {
            print("Error preparing \(DeleteFromSession)")
        }
        sqlite3_finalize(DeletePointer)
        return DeletedOK
    }
    
    /// Delete all entries in the Entries table with the passed session ID. Used in conjunction with `DeleteSession`
    /// for removing all traces of a logging session from the database.
    /// - Parameter ID: The ID of the session - each entry is marked with the session ID which is how we know which
    ///                 rows to delete.
    /// - Returns: True on success, false on failure. Error message sent to debug console.
    @discardableResult public static func DeleteEntriesWith(ID: UUID) -> Bool
    {
        if !Settings.GetBoolean(ForKey: .LoggingEnabled)
        {
            return false
        }
        let DeleteEntries = "DELETE FROM Entries WHERE SessionID = '\(ID.uuidString.uppercased())'"
        var DeletePointer: OpaquePointer? = nil
        var DeletedOK = false
        if sqlite3_prepare_v2(Handle, DeleteEntries, -1, &DeletePointer, nil) == SQLITE_OK
        {
            if sqlite3_step(DeletePointer) == SQLITE_DONE
            {
                DeletedOK = true
            }
            else
            {
                print("Error deleting entries: \(DeleteEntries)")
            }
        }
        else
        {
            print("Error preparing \(DeleteEntries)")
        }
        return DeletedOK
    }
}
