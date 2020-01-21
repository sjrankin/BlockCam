//
//  FileIO.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices
import Photos

/// Class to help with file I/O operations.
class FileIO
{
    /// Name of the scratch directory.
    public static let ScratchDirectory = "/Scratch"
    
    /// Name of the motion frame directory.
    public static let SceneFrames = "/SceneFrames"
    
    /// Name of the saved scenes directory.
    public static let SavedScenes = "/SavedScenes"
    
    /// Name of directory for stored pixellated images.
    public static let PixelDirectory = "/Pixellated"
    
    /// Name of directory for log database.
    public static let LogDirectory = "/Database"
    
    /// Initialize the directory structure. If the structure already exists, remove any existing files that are no longer needed.
    public static func InitializeDirectory()
    {
        if !DirectoryExists(ScratchDirectory)
        {
            CreateScratchDirectory()
        }
        else
        {
            ClearScratchDirectory()
        }
        if !DirectoryExists(PixelDirectory)
        {
            CreatePixelDirectory()
        }
        if !DirectoryExists(SceneFrames)
        {
            CreateSceneFrameDirectory()
        }
        else
        {
            ClearSceneFrameDirectory()
        }
        if !DirectoryExists(SavedScenes)
        {
            CreateSavedScenesDirectory()
        }
        InstallDatabase()
        ClearTempDirectory()
    }
    
    /// Installs the template database in the appropriate location. If the database file already exists, no action is taken.
    /// - Note: Calls to the logging manager should not be made from this function because this function is trying to ensure the
    ///         logging database is in place and if errors occur, it probably is not and the logging manager will not function
    ///         properly. For that reason, all output goes to the debug console.
    private static func InstallDatabase()
    {
        if !DirectoryExists(LogDirectory)
        {
            CreateLogDirectory()
        }
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(LogDirectory + "/AppLog.db")
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            return
        }
        if let DBTemplate = Bundle.main.path(forResource: "AppLog", ofType: "db")
        {
            let TemplateURL = URL(fileURLWithPath: DBTemplate)
            let DocDir = GetDocumentDirectory()!
            let DestURL = DocDir.appendingPathComponent(LogDirectory + "/AppLog.db")
            do
            {
                try FileManager.default.copyItem(at: TemplateURL, to: DestURL)
            }
            catch
            {
                fatalError("Error copying template database to working location. (\(error.localizedDescription))")
            }
        }
        else
        {
            print("Did not find database template 'AppLog.db' in resources.")
        }
    }
    
    /// Save a text file in the scratch directory.
    /// - Warning: A fatal error is generated on write failures.
    /// - Parameter With: The contents of the text file.
    /// - Parameter FileName: The name of the file to save.
    /// - Returns: Returns the URL of the saved file.
    public static func SaveTextFile(With Contents: String, FileName: String) -> URL
    {
        let ScratchDir = GetScratchDirectory()
        let ScratchFile = ScratchDir!.appendingPathComponent(FileName)
        do
        {
            try Contents.write(to: ScratchFile, atomically: true, encoding: String.Encoding.utf8)
        }
        catch
        {
            fatalError("Error writing log file to \(ScratchFile.path): \(error.localizedDescription)")
        }
        return ScratchFile
    }
    
    /// Returns the URL of the logging database.
    /// - Returns: URL of the logging database. Nil on error.
    public static func GetLogURL() -> URL?
    {
        let LogURL = GetDocumentDirectory()!.appendingPathComponent(LogDirectory + "/AppLog.db")
        return LogURL
    }
    
    /// Determines if the passed file exists.
    /// - Parameter FinalURL: The URL of the file.
    /// - Returns: True if the file exists, false if not.
    public static func FileExists(_ FinalURL: URL) -> Bool
    {
        return FileManager.default.fileExists(atPath: FinalURL.path)
    }
    
    /// Determines if a given directory exists.
    /// - Parameter DirectoryName: The name of the directory to check for existence.
    /// - Returns: True if the directory exists, false if not.
    public static func DirectoryExists(_ DirectoryName: String) -> Bool
    {
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        if CPath == nil
        {
            return false
        }
        return FileManager.default.fileExists(atPath: CPath!.path)
    }
    
    /// Create a directory in the document directory.
    /// - Parameter DirectoryName: Name of the directory to create.
    /// - Returns: URL of the newly created directory on success, nil on error.
    @discardableResult public static func CreateDirectory(DirectoryName: String) -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            Log.Message("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Returns the URL of the passed directory. The directory is assumed to be a sub-directory of the
    /// document directory.
    /// - Parameter DirectoryName: Name of the directory whose URL is returned.
    /// - Returns: URL of the directory on success, nil if not found.
    public static func GetDirectoryURL(DirectoryName: String) -> URL?
    {
        if !DirectoryExists(DirectoryName)
        {
            return nil
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        return CPath
    }
    
    /// Returns BlockCam's document directory.
    /// - Returns: The URL of the app's document directory.
    public static func GetDocumentDirectory() -> URL?
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// Create the scratch directory.
    /// - Returns: The scratch directory after it has been created successfully. Nil if the directory already exists or
    ///            could not be created.
    @discardableResult public static func CreateScratchDirectory() -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(ScratchDirectory)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            Log.Message("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Create the scene frames directory.
    /// - Returns: The scratch directory after it has been created successfully. Nil if the directory already exists or
    ///            could not be created.
    @discardableResult public static func CreateSceneFrameDirectory() -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(SceneFrames)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            Log.Message("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Creates the saved scenes directory.
    /// - Returns: The scratch directory after it has been created successfully. Nil if the directory already exists or
    ///            could not be created.
    @discardableResult public static func CreateSavedScenesDirectory() -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(SavedScenes)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            Log.Message("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Remove all files from the scene frame directory.
    public static func ClearSceneFrameDirectory()
    {
        var  DeleteCount = 0
        if let DirURL = GetSceneFramesDirectory()
        {
            do
            {
                if FileManager.default.changeCurrentDirectoryPath(DirURL.path)
                {
                    for File in try FileManager.default.contentsOfDirectory(atPath: ".")
                    {
                        try FileManager.default.removeItem(atPath: File)
                        DeleteCount = DeleteCount + 1
                    }
                }
            }
            catch
            {
                Log.Message("Error deleting file in scene frame directory: \(error.localizedDescription)")
            }
        }
        Log.Message("Deleted \(DeleteCount) objects in \(SceneFrames)")
    }
    
    /// Save an image in the scene frames directory.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SaveSceneFrame(_ Frame: UIImage, WithName: String) -> Bool
    {
        return SaveImageEx(Frame, WithName: WithName, InDirectory: SceneFrames, AsJPG: true)
    }
    
    /// Return the URL for the scene frames directory.
    /// - Returns: The URL of the scene frames directory. Nil if not found.
    public static func GetSceneFramesDirectory() -> URL?
    {
        if !DirectoryExists(SceneFrames)
        {
            CreateSceneFrameDirectory()
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(SceneFrames)
        return CPath
    }
    
    /// Create the pixel directory.
    /// - Returns: The pixel directory after it has been created successfully. Nil if the directory already exists or
    ///            could not be created.
    @discardableResult public static func CreatePixelDirectory() -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(PixelDirectory)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            Log.Message("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Create the app log directory.
    /// - Note: Do not call the logging manager from this function as it has not yet been fully initialized if this function
    ///         is being executed.
    /// - Returns: The pixel directory after it has been created successfully. Nil if the directory already exists or
    ///            could not be created.
    @discardableResult public static func CreateLogDirectory() -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(LogDirectory)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            print("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Return the URL for the saved scenes directory. Creates the directory if it does not exist.
    /// - Returns: THe URL of the saved scenes directory. Nil on error.
    public static func GetSavedScenesDirectory() -> URL?
    {
        if !DirectoryExists(SavedScenes)
        {
            CreateSavedScenesDirectory()
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(SavedScenes)
        return CPath
    }
    
    /// Return the URL for the scratch directory.
    /// - Returns: The URL of the scratch directory. Nil if not found.
    public static func GetScratchDirectory() -> URL?
    {
        if !DirectoryExists(ScratchDirectory)
        {
            CreateScratchDirectory()
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(ScratchDirectory)
        return CPath
    }
    
    /// Return the URL for the pixel directory.
    /// - Returns: The URL of the pixel directory. Nil if not found.
    public static func GetPixelDirectory() -> URL?
    {
        if !DirectoryExists(ScratchDirectory)
        {
            CreateScratchDirectory()
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(PixelDirectory)
        return CPath
    }
    
    /// Delete all files in the scratch directory.
    public static func ClearScratchDirectory()
    {
        var  DeleteCount = 0
        if let DirURL = GetScratchDirectory()
        {
            do
            {
                if FileManager.default.changeCurrentDirectoryPath(DirURL.path)
                {
                    for File in try FileManager.default.contentsOfDirectory(atPath: ".")
                    {
                        try FileManager.default.removeItem(atPath: File)
                        DeleteCount = DeleteCount + 1
                    }
                }
            }
            catch
            {
                Log.Message("Error deleting file in scratch directory: \(error.localizedDescription)")
            }
        }
        Log.Message("Deleted \(DeleteCount) objects in \(ScratchDirectory)")
    }
    
    /// Delete all files in the pixel directory.
    public static func ClearPixelDirectory()
    {
        var  DeleteCount = 0
        if let DirURL = GetPixelDirectory()
        {
            do
            {
                if FileManager.default.changeCurrentDirectoryPath(DirURL.path)
                {
                    for File in try FileManager.default.contentsOfDirectory(atPath: ".")
                    {
                        try FileManager.default.removeItem(atPath: File)
                        DeleteCount = DeleteCount + 1
                    }
                }
            }
            catch
            {
                Log.Message("Error deleting file in pixel directory: \(error.localizedDescription)")
            }
        }
        Log.Message("Deleted \(DeleteCount) objects in \(PixelDirectory)")
    }
    
    /// Return the URL of the temp directory.
    /// - Returns: URL of the temp directory.
    public static func GetTempDirectory() -> URL
    {
        return FileManager.default.temporaryDirectory
    }
    
    /// Delete all files in the temp directory.
    public static func ClearTempDirectory()
    {
        let DirURL = GetTempDirectory()
        do
        {
            if FileManager.default.changeCurrentDirectoryPath(DirURL.path)
            {
                for File in try FileManager.default.contentsOfDirectory(atPath: ".")
                {
                    try FileManager.default.removeItem(atPath: File)
                }
            }
        }
        catch
        {
            Log.Message("Error deleting file in temporary directory: \(error.localizedDescription)")
        }
    }
    
    /// Returns a temporary file name for files that live in the temp directory.
    /// - Returns: URL for a temporary file in the temp directory.
    public static func MakeTemporaryFileName() -> URL
    {
        let Name = ProcessInfo().globallyUniqueString
        let TempURL = GetTempDirectory().appendingPathComponent(Name)
        return TempURL
    }
    
    /// Create and return a temporary file name in the Scratch directory as an URL.
    /// - Parameter WithExtension: Optional extension for the file. This function does not add a period so the caller must
    ///                            include that with the value, eg, ".mp4".
    /// - Returns: URL of the file name in the Scratch directory.
    public static func MakeTemporaryFileNameInScratch(WithExtension: String = "") -> URL
    {
        let Name = ProcessInfo().globallyUniqueString + WithExtension
        let TempURL = GetScratchDirectory()?.appendingPathComponent(Name)
        return TempURL!
    }
    
    /// Delete the passed URL.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteTemporaryFile(_ FileURL: URL)
    {
        do
        {
            try FileManager.default.removeItem(at: FileURL)
        }
        catch
        {
            Log.Message("Error deleting temporary file.")
        }
    }
    
    /// Delete the specified file.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteFile(_ FileURL: URL)
    {
        do
        {
            try FileManager.default.removeItem(at: FileURL)
        }
        catch
        {
            Log.Message("Error deleting \(FileURL.path): \(error.localizedDescription)", FunctionName: #function)
        }
    }
    
    /// Delete the specified file. If the file does not exist, return without any errors being issued.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteIfPresent(_ FileURL: URL)
    {
        if FileManager.default.fileExists(atPath: FileURL.path)
        {
            DeleteFile(FileURL)
        }
    }
    
    /// Return the size of the file.
    /// - Parameter For: The URL of the file whose file size will be returned.
    /// - Returns: Size of the file in bytes.
    public static func FileSize(For: URL) -> UInt64
    {
        return For.FileSize
    }
    
    /// Return the size of the file.
    /// - Parameter For: The URL of the file whose file size will be returned.
    /// - Returns: Size of the file as a pretty string.
    public static func FileSizeString(For: URL) -> String
    {
        return For.FileSizeAsString
    }
    
    /// Loads an image from the file system. This is not intended for images from the photo album (and probably
    /// wouldn't work) but for images in our local directory tree.
    /// - Parameter Name: The name of the image to load.
    /// - Parameter InDirectory: Name of the directory where the file resides.
    /// - Returns: The image if found, nil if not found.
    public static func LoadImage(_ Name: String, InDirectory: String) -> UIImage?
    {
        if !DirectoryExists(InDirectory)
        {
            return nil
        }
        let DirURL = GetDirectoryURL(DirectoryName: InDirectory)
        return UIImage(contentsOfFile: (DirURL?.appendingPathComponent(Name).path)!)
    }
    
    
    /// Save an image to the specified directory.
    /// - Note: This function will check for the existence of the directory and create it if it does not exist.
    /// - Parameters:
    ///   - Image: The UIImage to save.
    ///   - WithName: The name to use when saving the image.
    ///   - InDirectory: The directory in which to save the image.
    ///   - AsJPG: If true, save as a .JPG image. If false, save as a .PNG image.
    /// - Returns: True on success, nil on failure.
    @discardableResult public static func SaveImageEx(_ Image: UIImage, WithName: String, InDirectory: String, AsJPG: Bool = true) -> Bool
    {
        var DirURL: URL? = nil
        if !DirectoryExists(InDirectory)
        {
            DirURL = CreateDirectory(DirectoryName: InDirectory)
        }
        else
        {
            DirURL = GetDirectoryURL(DirectoryName: InDirectory)
        }
        if AsJPG
        {
            if let Data = Image.jpegData(compressionQuality: 1.0)
            {
                let FileName = DirURL!.appendingPathComponent(WithName)
                do
                {
                    try Data.write(to: FileName)
                }
                catch
                {
                    Log.Message("Error writing \(FileName.path): \(error.localizedDescription)")
                    return false
                }
            }
        }
        else
        {
            if let Data = Image.pngData()
            {
                let FileName = DirURL!.appendingPathComponent(WithName)
                do
                {
                    try Data.write(to: FileName)
                }
                catch
                {
                    Log.Message("Error writing \(FileName.path): \(error.localizedDescription)")
                    return false
                }
            }
        }
        return true
    }
    
    /// Write pixellated data (formatted as a string) to the pixel directory.
    /// - Parameter Raw: The string that contains the pixellated data to write.
    /// - Parameter WithName: Name of the file to write to. If the file already exists, it will be overwritten.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SavePixellatedData(_ Raw: String, WithName: String) -> Bool
    {
        let FinalURL = GetDirectoryURL(DirectoryName: PixelDirectory)?.appendingPathComponent(WithName)
        do
        {
            try Raw.write(to: FinalURL!, atomically: true, encoding: String.Encoding.utf8)
        }
        catch
        {
            Log.Message("Error writing pixellated data to \(FinalURL!.path): \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Delete the specified pixellation data.
    /// - Parameter WithName: The name of the pixellated data to delete.
    /// Returns: True on success, false on failure.
    @discardableResult public static func DeletePixellatedData(WithName: String) -> Bool
    {
        let FinalURL = GetDirectoryURL(DirectoryName: PixelDirectory)?.appendingPathComponent(WithName)
        do
        {
            try FileManager.default.removeItem(atPath: FinalURL!.path)
        }
        catch
        {
            Log.Message("Error deleting pixellated data: \(FinalURL!.path), \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    /// Read a pixellation data file and return an array of colors.
    /// - Warning: A fatal error may be generated in `Utilities.MakeColorArray` if the raw data does not properly
    ///            conform to expectations.
    /// - Parameter From: The name of the pixellated data file. This file must reside in the `PixelDirectory`.
    /// - Returns: Array of colors on success, nil if the file was not found.
    public static func GetPixelData(From: String) -> [[UIColor]]?
    {
        let FinalURL = GetDirectoryURL(DirectoryName: PixelDirectory)?.appendingPathComponent(From)
        do
        {
            let RawData = try String(contentsOf: FinalURL!, encoding: .utf8)
            let ColorData = Utilities.MakeColorArray(From: RawData)
            return ColorData
        }
        catch
        {
            Log.Message("Could not read from \(FinalURL!.path)")
            return nil
        }
    }
    
    /// Returns a listing of the contents of the specified directory.
    /// - Parameter Directory: The directory whose contents will be returned.
    /// - Returns: Array of strings representing the contents of the specified directory on success, nil on error.
    public static func ContentsOfDirectory(_ Directory: String) -> [String]?
    {
        do
        {
            let Results = try FileManager.default.contentsOfDirectory(atPath: Directory)
            return Results
        }
        catch
        {
            Log.Message("Error getting contents of directory \(Directory): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns a listing of the contents of a special directory.
    /// - Note: Special directories consist of the set of named directories in this class.
    /// - Parameter Name: The name of the special directory.
    /// - Returns: array of strings representing the contents of the special directory on success, nil on error.
    public static func ContentsOfSpecialDirectory(_ Name: String) -> [String]?
    {
        if let SpecialDirectory = GetDirectoryURL(DirectoryName: Name)
        {
            do
            {
                let Contents = try FileManager.default.contentsOfDirectory(atPath: SpecialDirectory.path)
                return Contents
            }
            catch
            {
                Log.Message("Error getting contents of directory \(Name): \(error.localizedDescription)")
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    /// Save an image with metadata. This is intended to be used to save processed images. This function attempts to crop the image
    /// as specified by the user to avoid too much background.
    /// - Note:
    ///    - Some data is not saved unless the user explicitly tells BlockCam to save it. Specifically,
    ///      1. User name is not saved without explicit permission.
    ///      2. User copyright/legal is not saved without explicit permission.
    ///    - This function addes meta data with the following steps:
    ///      1. Save the image in the scratch directory.
    ///      2. Update the image file with metadata.
    ///      3. Save the updated image to the scratch directory.
    ///      4. Delete the original image.
    ///      5. Move the updated image to the photo roll.
    ///      6. Delete the updated image in the scratch directory.
    /// - Parameter ThisImage: The image to save.
    /// - Parameter UserString: It is assumed this is a list of parameters used to create the image and as such, is stored
    ///                         in the `Keywords` XMP section.
    /// - Parameter SaveInCameraRoll: If true, the image is saved in the camera roll.
    /// - Parameter Completion: Completion closure. Passes a bool indicating whether the save was successful (true) or not.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SaveCroppedImageWithMetaData(_ ThisImage: UIImage, UserString: String, SaveInCameraRoll: Bool = true,
                                                                       Completion: ((Bool) -> ())? = nil) -> Bool
    {
        var Cropped = ThisImage
        let Finder = ImageEdgeFinder()
        let Edges = Finder.FindEdgesIn(Cropped, NotInColor: UIColor.black)
        return SaveImageWithMetaData(Cropped, KeyValueString: UserString,
                                     SaveInCameraRoll: SaveInCameraRoll, Completion: Completion)
    }
    
    /// Save an image with metadata. This is intended to be used to save processed images.
    /// - Note:
    ///    - Some data is not saved unless the user explicitly tells BlockCam to save it. Specifically,
    ///      1. User name is not saved without explicit permission.
    ///      2. User copyright/legal is not saved without explicit permission.
    ///    - This function adds meta data with the following steps:
    ///      1. Save the image in the scratch directory.
    ///      2. Update the image file with metadata.
    ///      3. Save the updated image to the scratch directory.
    ///      4. Delete the original image.
    ///      5. Move the updated image to the photo roll.
    ///      6. Delete the updated image in the scratch directory.
    ///    - See:
    ///      - [CGImageMetadata.swift](https://gist.github.com/lacyrhoades/09d8a367125b6225df5038aec68ed9e7)
    ///      - [Set an EXIF user comment.](https://gist.github.com/kwylez/a4b6ec261e52970e1fa5dd4ccfe8898f)
    ///      - [Missing image metadata when saving update image into PhotoKit](https://stackoverflow.com/questions/41169156/missing-image-metadata-when-saving-updated-image-into-photokit)
    /// - Parameter ThisImage: The image to save.
    /// - Parameter KeyValueString: It is assumed this is a list of parameters used to create the image and as such, is stored
    ///                         in the `Keywords` XMP section. **If the passed string contains any non-ASCII characters, the entire
    ///                         sub-string will be removed before it is saved as metadata.**
    /// - Parameter SaveInCameraRoll: If true, the image is saved in the camera roll.
    /// - Parameter Completion: Completion closure. Passes a Bool indicating whether the save was successful (true) or not.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SaveImageWithMetaData(_ ThisImage: UIImage, KeyValueString: String, SaveInCameraRoll: Bool = true,
                                                                Completion: ((Bool) -> ())? = nil) -> Bool
    {
        let UserString = Utilities.ValidateKVPForASCIIOnly(KeyValueString, Separator: ";")
        let ImageData = ThisImage.jpegData(compressionQuality: 1.0)
        let ImageSource: CGImageSource = CGImageSourceCreateWithData(ImageData! as CFData, nil)!
        let FinalName = Utilities.MakeSequentialName("ImageSrc", Extension: "jpg")
        SaveImageEx(ThisImage, WithName: FinalName, InDirectory: ScratchDirectory, AsJPG: true)
        let FileURL = GetScratchDirectory()?.appendingPathComponent(FinalName)
        let DestURL = GetScratchDirectory()?.appendingPathComponent(Utilities.MakeSequentialName("ImageEx", Extension: "jpg"))
        let Destination: CGImageDestination = CGImageDestinationCreateWithURL(DestURL! as CFURL,
                                                                              kUTTypeJPEG, 1, nil)!
        
        let SoftwareTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceTIFF,
                                                   kCGImageMetadataPrefixTIFF,
                                                   kCGImagePropertyTIFFSoftware,
                                                   .string,
                                                   Versioning.ApplicationName + ", " + Versioning.MakeVersionString() + " " + Versioning.MakeBuildString() as CFString)
        
        let MetaData = CGImageMetadataCreateMutable()
        var TagPath = "tiff:Software" as CFString
        var result = CGImageMetadataSetTagWithPath(MetaData, nil, TagPath, SoftwareTag!)
        
        if Settings.GetBoolean(ForKey: .AddUserDataToExif)
        {
            if let RawCopyright = Settings.GetString(ForKey: .UserCopyright)
            {
                if RawCopyright.count > 0
                {
                    let CopyrightPath = "\(kCGImageMetadataPrefixTIFF):\(kCGImagePropertyTIFFCopyright)" as CFString
                    guard let CopyrightTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceTIFF,
                                                                      kCGImageMetadataPrefixTIFF, kCGImagePropertyTIFFCopyright,
                                                                      .string,
                                                                      RawCopyright as CFString) else
                    {
                        Log.Message("Error creating user copyright tag.")
                        Completion?(false)
                        return false
                    }
                    CGImageMetadataSetTagWithPath(MetaData, nil, CopyrightPath, CopyrightTag)
                }
            }
            if let RawUserName = Settings.GetString(ForKey: .UserName)
            {
                if RawUserName.count > 0
                {
                    let ArtistPath = "\(kCGImageMetadataPrefixTIFF):\(kCGImagePropertyTIFFArtist)" as CFString
                    guard let AuthorTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceTIFF,
                                                                   kCGImageMetadataPrefixTIFF, kCGImagePropertyTIFFArtist,
                                                                   .string,
                                                                   RawUserName as CFString) else
                    {
                        Log.Message("Error creating user name tag.")
                        Completion?(false)
                        return false
                    }
                    CGImageMetadataSetTagWithPath(MetaData, nil, ArtistPath, AuthorTag)
                }
            }
        }
        
        let KeywordArray = NSMutableArray()
        let WordParts = UserString.split(separator: ";", omittingEmptySubsequences: true)
        for Word in WordParts
        {
            KeywordArray.add(String(Word))
        }
        let KeyWordsTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceIPTCCore,
                                                   kCGImageMetadataPrefixIPTCCore,
                                                   kCGImagePropertyIPTCKeywords,
                                                   .arrayOrdered,
                                                   KeywordArray as CFTypeRef)
        TagPath = "\(kCGImageMetadataPrefixXMPBasic):\(kCGImagePropertyIPTCKeywords)" as CFString
        result = CGImageMetadataSetTagWithPath(MetaData, nil, TagPath, KeyWordsTag!)
        
        let XMPData = CGImageMetadataCreateXMPData(MetaData, nil)
        let XMP = String(data: XMPData! as Data, encoding: .utf8)
        let FinalXMPData = XMP!.data(using: .ascii)! as CFData
        let FinalMeta = CGImageMetadataCreateFromXMPData(FinalXMPData)!
        
        let DestOptions: [String: Any] =
            [
                kCGImageDestinationMergeMetadata as String: NSNumber(value: 1),
                kCGImageDestinationMetadata as String: FinalMeta
        ]
        var CompletedOK = true
        let CFDestOptions = DestOptions as CFDictionary
        var error: Unmanaged<CFError>? = nil
        withUnsafeMutablePointer(to: &error,
                                 {
                                    ptr in
                                    result = CGImageDestinationCopyImageSource(Destination, ImageSource, CFDestOptions, ptr)
                                    if !result
                                    {
                                        CompletedOK = false
                                        Log.Message("Error saving image: \(DestURL!.path)")
                                    }
        })
        if !CompletedOK
        {
            Completion?(false)
            return false
        }
        
        DeleteFile(FileURL!)
        if SaveInCameraRoll
        {
            var AssetID: String? = nil
            PHPhotoLibrary.shared().performChanges(
                {
                    let CreationRequest = PHAssetCreationRequest.forAsset()
                    CreationRequest.addResource(with: .photo, fileURL: DestURL!, options: nil)
                    AssetID = CreationRequest.placeholderForCreatedAsset?.localIdentifier
            },
                completionHandler:
                {
                    saved, error in
                    if saved
                    {
                        self.DeleteFile(DestURL!)
                    }
                    else
                    {
                        CompletedOK = false
                        Log.Message("Failed to move to photo roll: \((error?.localizedDescription)!)")
                    }
            }
            )
        }
        
        Completion?(CompletedOK)
        return true
    }
}


