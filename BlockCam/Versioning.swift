//
//  Versioning.swift
//  BlockCam
//  Adapted from Fouris and GPS Log, December 2019
//
//  Created by Stuart Rankin on 4/10/19.
//  Copyright © 2019, 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains versioning and copyright information. The contents of this file are automatically updated with each
/// build by the VersionUpdater utility. This file also contains functions to return versioning information in various
/// formats.
/// - Important:
///     - Depending on when the automatic update to this file happens, the build times and numbers may be one off; this will
///       happen if this file is updated as a post-build step. To avoid this, use a pre-build step instead.
///     - The formation of the static delcarations is important. All must be in the form `public static let Variable: Type = "string"`
///       with no trailing comments.
///     - The **VersionUpdater** program requires the following variables to be in place in order to update both this file and
///       and the README.md file:
///       - `BuildTime`
///       - `BuildDate`
///       - `BuildIncrement`
///       - `Build`
///       - `BuildID`
///       - `MajorVersion`
///       - `MinorVersion`
///       - `Tag`
public class Versioning: CustomStringConvertible
{
    /// Major version number.
    public static let MajorVersion: String = "0"
    
    /// Minor version number.
    public static let MinorVersion: String = "9"
    
    /// Potential version suffix.
    public static let VersionSuffix: String = ""
    
    /// Name of the application.
    public static let ApplicationName = "BlockCam"
    
    /// Tag for the application.
    public static let Tag: String = "Alpha"
    
    /// ID of the application.
    public static let ProgramID = "28b73255-d8bf-4333-95b4-17a1e70f36e5"
    
    /// The intended OS for the program.
    public static let IntendedOS: String = "iOS"
    
    /// Returns a standard-formatted version string in the form of "Major.Minor" with optional
    /// version suffix.
    /// - Parameter IncludeVersionSuffix: If true and the VersionSuffix value is non-empty, the contents
    ///                                   of VersionSuffix will be appended (with a leading space) to the
    ///                                   returned string.
    /// - Parameter IncludeVersionPrefix: If true, the word "Version" is prepended to the returned string.
    /// - Returns: Standard version string.
    public static func MakeVersionString(IncludeVersionSuffix: Bool = false,
                                         IncludeVersionPrefix: Bool = true) -> String
    {
        let VersionLabel = IncludeVersionPrefix ? "Version " : ""
        var Final = "\(VersionLabel)\(MajorVersion).\(MinorVersion)"
        if IncludeVersionSuffix
        {
            if !VersionSuffix.isEmpty
            {
                Final = Final + " " + VersionSuffix
            }
        }
        return Final
    }
    
    /// Create and return a simple version string.
    /// - Parameter NoBuild: If true, the build number will not be included. Default is false
    /// - Note: The version string will consist of: `<Application Name> <Version>, (<Build>)` or `<Application Name> <Version>`,
    ///         depending on the value of `NoBuild`.
    public static func MakeSimpleVersionString(NoBuild: Bool = false) -> String
    {
        var Label = ApplicationName
        Label.append(" " + "\(MajorVersion)" + "." + "\(MinorVersion)")
        if !NoBuild
        {
        Label.append(", (\(Build))")
        }
        return Label
    }
    
    /// Returns a very simple version string in the form of v{Major}.{Minor}.
    /// - Returns: Simple version string.
    public static func VerySimpleVersionString() -> String
    {
        return "v\(MajorVersion).\(MinorVersion)"
    }
    
    /// Returns the version number as a double value.
    /// - Returns: Double with the significant digits as the major version, and decimal digits as the minor version number.
    ///            `0.0` returned on error.
    public static func VersionAsNumber() -> Double
    {
        if let Final = Double("\(MajorVersion).\(MinorVersion)")
        {
            return Final
        }
        return 0.0
    }
    
    /// Publishes the version string to the debug console.
    /// - Parameter LinePrefix: The prefix for each line of the version block. Defaults to empty string.
    public static func PublishVersion(_ LinePrefix: String = "")
    {
        print(MakeVersionBlock(LinePrefix))
    }
    
    /// Build number.
    public static let Build: Int = 2087
    
    /// Build increment.
    private static let BuildIncrement = 1
    
    /// Build ID.
    public static let BuildID: String = "72C2484B-6760-42D8-A159-19828D783B69"
    
    /// Build date.
    public static let BuildDate: String = "4 March 2020"
    
    /// Build Time.
    public static let BuildTime: String = "18:01"
    
    /// Holds the release build flag.
    private static var _IsReleaseBuild: Bool = false
    /// Get or set the release build flag. This is set at run-time by the calling program. Defaults to `false`.
    public static var IsReleaseBuild: Bool
    {
        get
        {
            return _IsReleaseBuild
        }
        set
        {
            _IsReleaseBuild = newValue
        }
    }
    
    /// Return a standard build string.
    ///
    /// - Parameter IncludeBuildPrefix: If true, the word "Build" is prepended to the returned string.
    /// - Returns: Standard build string
    public static func MakeBuildString(IncludeBuildPrefix: Bool = true) -> String
    {
        let BuildLabel = IncludeBuildPrefix ? "Build " : ""
        let Final = "\(BuildLabel)\(Build), \(BuildDate) \(BuildTime)"
        return Final
    }
    
    /// Copyright years.
    public static let CopyrightYears = [2019, 2020]
    
    /// Legal holder of the copyright.
    public static let CopyrightHolder = "Stuart Rankin"
    
    /// Returns the list of authors. Order of names is Given then Family. If a person has multiple names, the family name
    /// should be the last in the string. Names should be separated by single spaces.
    public static let Authors =
        [
            "Stuart Rankin"
    ]
    
    /// With a string of words separated by spaces, move the last word to the first position.
    /// - Parameter Source: Source string.
    /// - Returns: String with the last word moved to the front of the string.
    private static func MoveLastToFirst(_ Source: String) -> String
    {
        var Parts = Source.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count == 1
        {
            return Source
        }
        let Last = Parts.removeLast()
        var Result = String(Last)
        Result.append(" ")
        for Part in Parts
        {
            Result.append(String(Part))
            Result.append(" ")
        }
        Result = Result.trimmingCharacters(in: .whitespaces)
        return Result
    }
    
    /// With a string of words separated by spaces, move the first word to the last position.
    /// - Parameter Source: Source string.
    /// - Returns: String with the first word moved to the end of the string.
    private static func MoveFirstToLast(_ Source: String) -> String
    {
        var Parts = Source.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count == 1
        {
            return Source
        }
        let First = Parts.removeFirst()
        var Result = ""
        for Part in Parts
        {
            Result.append(String(Part))
            Result.append(" ")
        }
        Result.append(String(First))
        return Result
    }
    
    /// Returns the list of authors.
    /// - Note: If there is only one author, that name is returned without further processing. If there are no authors in `Authors`,
    ///         an empty string is returned.
    /// - Parameter Alphabetize: If true, the names of the authors are returned in alphabetical order keyed on each author's last
    ///                          name. See notes for `Authors`.
    /// - Returns: List of comma-separated authors, optionally sorted by last name.
    public static func AuthorList(Alphabetize: Bool = true) -> String
    {
        if Authors.count < 1
        {
            return ""
        }
        var Names = Authors
        if Names.count == 1
        {
            //If there is only one name, just return it and don't worry about sorting.
            return Names[0]
        }
        if Alphabetize
        {
            var Reversed = [String]()
            for Name in Names
            {
                let Rearranged = MoveLastToFirst(Name)
                Reversed.append(Rearranged)
            }
            Reversed = Reversed.sorted()
            Names.removeAll()
            for Name in Reversed
            {
                let Original = MoveFirstToLast(Name)
                Names.append(Original)
            }
        }
        var Final = ""
        for Index in 0 ..< Names.count
        {
            Final.append(Names[Index])
            if Index < Names.count - 1
            {
                Final.append(", ")
            }
        }
        return Final
    }
    
    /// Returns copyright text.
    /// - Returns: Program copyright text.
    public static func CopyrightText(ExcludeCopyrightString: Bool = false) -> String
    {
        var Years = Versioning.CopyrightYears
        var CopyrightYears = ""
        if Years.count > 1
        {
            Years = Years.sorted()
            CopyrightYears = "\(Years.first!) - \(Years.last!)"
        }
        else
        {
            CopyrightYears = String(describing: Years[0])
        }
        var CopyrightTextString = ""
        if ExcludeCopyrightString
        {
            CopyrightTextString = "\(CopyrightYears) \(CopyrightHolder)"
        }
        else
        {
            CopyrightTextString = "Copyright © \(CopyrightYears) \(CopyrightHolder)"
        }
        return CopyrightTextString
    }
    
    /// Return the program ID as a UUID.
    public static func ProgramIDAsUUID() -> UUID
    {
        return UUID(uuidString: ProgramID)!
    }
    
    /// Returns a list of parts that make up a version block.
    /// - Returns: List of tuples that make up a version block. The first item in the tuple is the header (if
    ///            desired) and the second item is the actual data for the version block.
    public static func MakeVersionParts() -> [(String, String)]
    {
        var Parts = [(String, String)]()
        Parts.append(("Name", ApplicationName))
        Parts.append(("Version", MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: true)))
        Parts.append(("Build", MakeBuildString()))
        Parts.append(("Build ID", BuildID))
        Parts.append(("Copyright", CopyrightText()))
        Parts.append(("Program ID", ProgramID))
        Parts.append(("Tag", Tag))
        Parts.append(("IsReleased", "\(IsReleaseBuild)"))
        return Parts
    }
    
    /// Returns a block of text with most of the versioning information.
    /// - Parameter WithLinePrefix: The string to prefix each line with. Defaults to "". Available mainly for
    ///                             when dumping the version block to the debug console. This function will add
    ///                             a whitespace character between any non-empty value and the version block text
    ///                             on each line.
    /// - Returns: Most versioning information, each piece of information on a separate line.
    public static func MakeVersionBlock(_ WithLinePrefix: String = "") -> String
    {
        let Prefix = WithLinePrefix.isEmpty ? "" : WithLinePrefix + " "
        var Block = Prefix + ApplicationName + "\n"
        Block = Block + Prefix + MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: true) + "\n"
        Block = Block + Prefix + MakeBuildString() + "\n"
        Block = Block + Prefix + "Build ID " + BuildID + "\n"
        Block = Block + Prefix + CopyrightText() + "\n"
        Block = Block + Prefix + "Program ID " + ProgramID + "\n"
        Block = Block + Prefix + Tag + ", Build Type: " + String(IsReleaseBuild ? "Release" : "Debug")
        return Block
    }
    
    /// Returns the version block as an attributed string with colors and formats as sepcified in the parameters.
    /// - Parameter TextColor: Color of the normal (eg, payload) text.
    /// - Parameter HeaderColor: Header color for those lines with headers.
    /// - Parameter FontName: Name of the font.
    /// - Parameter FontSize: Size of the font.
    /// - Returns: Attributed string with the version block.
    public static func MakeAttributedVersionBlockEx(TextColor: UIColor = UIColor.blue, HeaderColor: UIColor = UIColor.black,
                                                    FontName: String = "Avenir", HeaderFontName: String = "Avenir-Heavy",
                                                    FontSize: Double = 24.0) -> NSAttributedString
    {
        let Parts = MakeVersionParts()
        let HeaderFont = UIFont(name: HeaderFontName, size: CGFloat(FontSize))
        let StandardFont = UIFont(name: FontName, size: CGFloat(FontSize))
        
        let HeaderAttributes: [NSAttributedString.Key: Any] =
            [
                .font: HeaderFont as Any,
                .foregroundColor: HeaderColor as Any
        ]
        let Line1Attributes: [NSAttributedString.Key: Any] =
            [
                .font: UIFont(name: HeaderFontName, size: CGFloat(FontSize + 4)) as Any,
                .foregroundColor: TextColor as Any
        ]
        let StandardLineAttributes: [NSAttributedString.Key: Any] =
            [
                .font: StandardFont as Any,
                .foregroundColor: TextColor as Any
        ]
        
        let Line1 = NSMutableAttributedString(string: Parts[0].1 + "\n", attributes: Line1Attributes)
        let Line2H = NSMutableAttributedString(string: "Version ", attributes: HeaderAttributes)
        let Line2T = NSMutableAttributedString(string: MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: false) + "\n", attributes: StandardLineAttributes)
        let Line3H = NSMutableAttributedString(string: "Build ", attributes: HeaderAttributes)
        let Line3T = NSMutableAttributedString(string: MakeBuildString(IncludeBuildPrefix: false) + "\n", attributes: StandardLineAttributes)
        let Line4H = NSMutableAttributedString(string: Parts[3].0 + " ", attributes: HeaderAttributes)
        let Line4T = NSMutableAttributedString(string: Parts[3].1 + "\n", attributes: StandardLineAttributes)
        let Line4xH = NSMutableAttributedString(string: "Build type ", attributes: HeaderAttributes)
        let IsRelease = Bool(Parts[7].1)!
        let Line4xT = NSMutableAttributedString(string: String(IsRelease ? "Release\n" : "Debug\n"), attributes: StandardLineAttributes)
        let Line5H = NSMutableAttributedString(string: "Copyright © ", attributes: HeaderAttributes)
        let Line5T = NSMutableAttributedString(string: CopyrightText(ExcludeCopyrightString: true) + "\n", attributes: StandardLineAttributes)
        let Line6H = NSMutableAttributedString(string: Parts[5].0 + " ", attributes: HeaderAttributes)
        let Line6T = NSMutableAttributedString(string: Parts[5].1, attributes: StandardLineAttributes)
        let Working = NSMutableAttributedString()
        Working.append(Line1)
        Working.append(Line2H)
        Working.append(Line2T)
        Working.append(Line3H)
        Working.append(Line3T)
        Working.append(Line4H)
        Working.append(Line4T)
        Working.append(Line4xH)
        Working.append(Line4xT)
        Working.append(Line5H)
        Working.append(Line5T)
        Working.append(Line6H)
        Working.append(Line6T)
        return Working
    }
    
    /// Returns the version block as an attributed string with colors and formats as sepcified in the parameters.
    /// - Parameter TextColor: Color of the normal (eg, payload) text.
    /// - Parameter HeaderColor: Header color for those lines with headers.
    /// - Parameter FontName: Name of the font.
    /// - Parameter FontSize: Size of the font.
    /// - Returns: Attributed string with the version block.
    public static func MakeAttributedVersionBlock(TextColor: UIColor = UIColor.blue, HeaderColor: UIColor = UIColor.black,
                                                  FontName: String = "Avenir", HeaderFontName: String = "Avenir-Heavy",
                                                  FontSize: Double = 24.0) -> NSAttributedString
    {
        let Parts = MakeVersionParts()
        let HeaderFont = UIFont(name: HeaderFontName, size: CGFloat(FontSize))
        let StandardFont = UIFont(name: FontName, size: CGFloat(FontSize))
        
        let HeaderAttributes: [NSAttributedString.Key: Any] =
            [
                .font: HeaderFont as Any,
                .foregroundColor: HeaderColor as Any
        ]
        let Line1Attributes: [NSAttributedString.Key: Any] =
            [
                .font: UIFont(name: HeaderFontName, size: CGFloat(FontSize + 4)) as Any,
                .foregroundColor: TextColor as Any
        ]
        let StandardLineAttributes: [NSAttributedString.Key: Any] =
            [
                .font: StandardFont as Any,
                .foregroundColor: TextColor as Any
        ]
        
        let Line1 = NSMutableAttributedString(string: Parts[0].1 + "\n", attributes: Line1Attributes)
        let Line2 = NSMutableAttributedString(string: Parts[1].1 + "\n", attributes: StandardLineAttributes)
        let Line3 = NSMutableAttributedString(string: Parts[2].1 + "\n", attributes: StandardLineAttributes)
        let Line4H = NSMutableAttributedString(string: Parts[3].0 + " ", attributes: HeaderAttributes)
        let Line4T = NSMutableAttributedString(string: Parts[3].1 + "\n", attributes: StandardLineAttributes)
        let Line4xH = NSMutableAttributedString(string: "Build type ", attributes: HeaderAttributes)
        let IsRelease = Bool(Parts[7].1)!
        let Line4xT = NSMutableAttributedString(string: String(IsRelease ? "Release\n" : "Debug\n"), attributes: StandardLineAttributes)
        let Line5 = NSMutableAttributedString(string: Parts[4].1 + "\n", attributes: StandardLineAttributes)
        let Line6H = NSMutableAttributedString(string: Parts[5].0 + " ", attributes: HeaderAttributes)
        let Line6T = NSMutableAttributedString(string: Parts[5].1, attributes: StandardLineAttributes)
        let Working = NSMutableAttributedString()
        Working.append(Line1)
        Working.append(Line2)
        Working.append(Line3)
        Working.append(Line4H)
        Working.append(Line4T)
        Working.append(Line4xH)
        Working.append(Line4xT)
        Working.append(Line5)
        Working.append(Line6H)
        Working.append(Line6T)
        return Working
    }
    
    /// Return an XML-formatted key-value pair string.
    /// - Parameters:
    ///   - Key: The key part of the key-value pair.
    ///   - Value: The value part of the key-value pair.
    /// - Returns: XML-formatted key-value pair string.
    private static func MakeKVP(_ Key: String, _ Value: String) -> String
    {
        let KVP = "\(Key)=\"\(Value)\""
        return KVP
    }
    
    /// Emit version information as an XML string.
    /// - Parameter LeadingSpaceCount: The number of leading spaces to insert before
    ///                                each line of the returned result. If not specified,
    ///                                no extra leading spaces are used.
    /// - Returns: XML string with version information.
    public static func EmitXML(_ LeadingSpaceCount: Int = 0) -> String
    {
        let Spaces = String(repeating: " ", count: LeadingSpaceCount)
        var Emit = Spaces + "<Version "
        Emit = Emit + MakeKVP("Application", ApplicationName) + " "
        Emit = Emit + MakeKVP("Version", MajorVersion + "." + MinorVersion) + " "
        Emit = Emit + MakeKVP("Build", String(describing: Build)) + " "
        Emit = Emit + MakeKVP("BuildDate", BuildDate + ", " + BuildTime) + " "
        Emit = Emit + MakeKVP("BuildID", BuildID)
        Emit = Emit + MakeKVP("Tag", Tag)
        Emit = Emit + MakeKVP("IsReleased", "\(IsReleaseBuild)")
        Emit = Emit + ">\n"
        Emit = Emit + Spaces + "  " + CopyrightText() + "\n"
        Emit = Emit + Spaces + "</Version>"
        return Emit
    }
    
    /// Returns versioning data as an array of key-value pairs.
    /// - Returns: Array of key value pairs with versioning data.
    public static func GetKeyValueData() -> [(String, String)]
    {
        var KVP = [(String, String)]()
        KVP.append(("Application", ApplicationName))
        KVP.append(("Version", MajorVersion + "." + MinorVersion))
        KVP.append(("Build", String(describing: Build)))
        KVP.append(("BuildDate", BuildDate + ", " + BuildTime))
        KVP.append(("BuildID", BuildID))
        KVP.append(("Copyright", CopyrightText()))
        KVP.append(("Tag", Tag))
        KVP.append(("IsReleased", "\(IsReleaseBuild)"))
        return KVP
    }
    
    /// Allows a caller to print the contents of the class easily.
    /// - Note:
    ///   - The returned string is from the `EmitXML()` function.
    ///   - This is an instance property and so probably won't be called. `CustomStringConvertible` does not allow for static
    ///     versions of `description` unfortunately. However, this property is provided just in case there is a time when the
    ///     caller may want to print an instance of the static class, which doesn't really make sense.
    public var description: String
    {
        get
        {
            return Versioning.EmitXML()
        }
    }
}
