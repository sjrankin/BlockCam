//
//  VideoAssembly.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

/// Class that combines UIImages into a video and saves the result in the photo roll.
/// - Note: See [Create video from UIImages](https://riptutorial.com/ios/example/31830/create-video-from-uiimages)
class VideoAssembly
{
    /// Resize an image such that the maximum dimension is no larger than `MaxDimension`. If the original dimensions of the
    /// image are less than `MaxDimension`, the original image is returned unchanged.
    /// - Parameter Image: The image to potentially resize.
    /// - Parameter MaxDimension: The maximum allowable size of the image.
    /// - Returns: Potentially resized image.
    static func ResizeToMaxDimension(_ Image: UIImage, _ MaxDimension: Int) -> UIImage
    {
        let OldMax = max(Image.size.width, Image.size.height)
        if OldMax < CGFloat(MaxDimension)
        {
            return Image
        }
        return Generator.ResizeImage(Image: Image, Longest: CGFloat(MaxDimension))
    }
    
    /// Assemble all images in the passed file into a single video and save it in the photo roll.
    /// - Notes: Assumes all files in the specified directory are related, but this is not necessary.
    /// - Notes: Assumes all file names can be sorted alphabetically to be in the proper order.
    /// - Parameter FilesInDirectory: The name of the directory where the image files will be found.
    /// - Parameter TargetURL: Where to store the temporary video file. It is important this URL have a path with a valid
    ///                        extension or PHPhotoLibrary will throw an error.
    /// - Parameter FrameDuration: Duration of each frame in seconds.
    /// - Parameter SaveToPhotoRoll: If true, the final video is save to the photo roll. If false, it is not saved (and may be
    ///                              deleted very quickly as BlockCam attempts to clear the scratch and/or temp folders regularly).
    /// - Parameter Parent: The parent view controller. Use when crashes occur.
    /// - Parameter StatusHandler: Handler to report status percent completes.
    /// - Parameter Completed: Completion handler. The `Bool` parameter is to report success or failure.
    static func AssembleAndSave(FilesInDirectory: String, TargetURL: URL, SaveToPhotoRoll: Bool = true,
                                Parent: UIViewController, StatusHandler: ((Double, UIColor) -> ())? = nil,
                                Completed: ((Bool) -> ())? = nil)
    {
        if var FileNames = FileIO.ContentsOfSpecialDirectory(FilesInDirectory)
        {
            FileNames.sort()
            var Frames = [UIImage]()
            var ImageSize: CGSize? = nil
            
            
            
            for Name in FileNames
            {
                autoreleasepool
                    {
                        if var Image = FileIO.LoadImage(Name, InDirectory: FilesInDirectory)
                        {
                            Image = ResizeToMaxDimension(Image, 1080)
                            if ImageSize == nil
                            {
                                ImageSize = Image.size
                            }
                            else
                            {
                                if ImageSize != Image.size
                                {
                                    Log.AbortMessage("Variant image size found.")
                                    {
                                        Message in
                                        fatalError(Message)
                                    }
                                }
                            }
                            Frames.append(Image)
                        }
                        else
                        {
                            Log.Message("Error loading image file \(Name)")
                        }
                }
            }
            VideoAssembly.AssembleAndSave(Frames, Size: ImageSize!, TargetURL: TargetURL, FrameDuration: /*1.0 / 30.0*/30.0,
                                          SaveToPhotoRoll: SaveToPhotoRoll, Parent: Parent, SaveFrames: false,
                                          StatusHandler: StatusHandler, Completed: Completed)
        }
        else
        {
            Log.Message("No files found in \(FilesInDirectory)")
        }
    }
    
    private static func CreateAssetWriter(TargetPath: String, ImageSize: CGSize) -> AVAssetWriter?
    {
        let PathURL = URL(fileURLWithPath: TargetPath)
        do
        {
            let NewWriter = try AVAssetWriter(outputURL: PathURL, fileType: AVFileType.mp4)
            let VideoSettings: [String: Any] =
            [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: NSNumber(value: Int(ImageSize.width)),
                AVVideoHeightKey: NSNumber(value: Int(ImageSize.height)),
                AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
            ]
            let AssetWriteVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: VideoSettings)
            NewWriter.add(AssetWriteVideoInput)
            return NewWriter
        }
        catch
        {
            Log.Message("Error creating AVAssetWriter: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Assemble the passed set of UIImages as a video and save it in the photo roll.
    /// - Parameter Frames: The set of images to save as a video. Each image must have the same dimensions.
    /// - Parameter Size: The final size of each image.
    /// - Parameter TargetURL: Where to store the temporary video file. It is important this URL have a path with a valid
    ///                        extension or PHPhotoLibrary will throw an error.
    /// - Parameter FrameDuration: Duration of each frame in seconds.
    /// - Parameter SaveToPhotoRoll: If true, the final video is save to the photo roll. If false, it is not saved (and may be
    ///                              deleted very quickly as BlockCam attempts to clear the scratch and/or temp folders regularly).
    /// - Parameter Parent: The parent view controller. Use when crashes occur.
    /// - Parameter SaveFrames: If true, frames are saved in the scratch directory.
    /// - Parameter StatusHandler: Handler to report status percent completes.
    /// - Parameter Completed: Completion handler. The `Bool` parameter is to report success or failure.
    static func AssembleAndSave(_ Frames: [UIImage], Size: CGSize, TargetURL: URL, FrameDuration: Double,
                                SaveToPhotoRoll: Bool = true, Parent: UIViewController, SaveFrames: Bool = false,
                                StatusHandler: ((Double, UIColor) -> ())? = nil, Completed: ((Bool) -> ())? = nil)
    {
        Log.Message("Saving images of size: \(Size)")
        do
        {
            let Writer = try AVAssetWriter(outputURL: TargetURL, fileType: AVFileType.mp4)
            let Params: [String: Any] =
                [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: NSNumber(value: Int(Size.width)),
                    AVVideoHeightKey: NSNumber(value: Int(Size.height)),
                    AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
            ]
            let WriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: Params)
            if Writer.canAdd(WriterInput)
            {
                Writer.add(WriterInput)
            }
            else
            {
                Crash.ShowCrashAlert(WithController: Parent, "Error",
                                     "Error adding writer input to asset writer. BlockCam will close.")
                Log.AbortMessage("Error adding input to writer.")
                {
                    Message in
                    fatalError(Message)
                }
            }
            let Attributes: [String: Any] =
                [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                    kCVPixelBufferWidthKey as String: NSNumber(value: Float(Size.width)),
                    kCVPixelBufferHeightKey as String: NSNumber(value: Float(Size.height)),
                    kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
                    kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
            ]
            let WriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: WriterInput,
                                                                     sourcePixelBufferAttributes: Attributes)
            Writer.startWriting()
            Writer.startSession(atSourceTime: CMTime.zero)
            let WriterQueue = DispatchQueue(label: "VideoWriterQueue")
            StatusHandler?(0.0, UIColor.systemBlue)
            WriterInput.requestMediaDataWhenReady(on: WriterQueue, using:
                {
                    for Index in 0 ..< Frames.count
                    {
                        autoreleasepool
                            {
                                while !WriterInput.isReadyForMoreMediaData
                                {
                                    Thread.sleep(forTimeInterval: 0.01)
                                }
                                let Image = Frames[Index]
                                if SaveFrames
                                {
                                    FileIO.SaveImageEx(Image, WithName: "P\(Index).jpg", InDirectory: FileIO.ScratchDirectory, AsJPG: true)
                                }
                                var Buffer: CVPixelBuffer? = nil
                                let Attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                                                  kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
                                let Status = CVPixelBufferCreate(kCFAllocatorDefault, Int(Size.width), Int(Size.height),
                                                                 kCVPixelFormatType_32ARGB, Attributes, &Buffer)
                                guard Status == kCVReturnSuccess else
                                {
                                    Crash.ShowCrashAlert(WithController: Parent, "Error",
                                                         "Error creating pixel buffer. BlockCam will close.")
                                    Log.AbortMessage("Error creating pixel buffer.")
                                    {
                                        Message in
                                        fatalError(Message)
                                    }
                                    //The return will never be executed but the compiler gets cranky if a fatalError is in a
                                    //closure (mainly because it can't figure out whether it will actually be called or not)
                                    //to to ensure compilability, we include the never-will-be-executed return statement.
                                    return
                                }
                                let Context = CIContext()
                                let CIImg = CIImage(cgImage: Image.cgImage!)
                                Context.render(CIImg, to: Buffer!)
                                let FrameTime = CMTimeMakeWithSeconds(Float64(Double(Index) * FrameDuration), preferredTimescale: 100)
                                if !WriterAdaptor.append(Buffer!, withPresentationTime: FrameTime)
                                {
                                    Crash.ShowCrashAlert(WithController: Parent, "Error",
                                                         "Error appending image at index \(Index) to the asset writer. BlockCam will close.")
                                    Log.AbortMessage("Error appending image at index \(Index) to the writer. Image size = \(Image.size), FrameTime = \(FrameTime.value).")
                                    {
                                        Message in
                                        fatalError(Message)
                                    }
                                }
                                StatusHandler?(Double(Index) / Double(Frames.count), UIColor.systemBlue)
                        }
                    }
                    WriterInput.markAsFinished()
                    Writer.finishWriting(completionHandler:
                        {
                            let Success = Writer.status == AVAssetWriter.Status.completed
                            if Success
                            {
                                if SaveToPhotoRoll
                                {
                                    SaveVideoToPhotoRoll(SourceVideo: TargetURL, Completed: Completed)
                                }
                            }
                            else
                            {
                                Crash.ShowCrashAlert(WithController: Parent, "Error",
                                                     "Asset writer failed. BlockCam will close.")
                                Log.Message("Writer.error=\((Writer.error?.localizedDescription)!)")
                                Log.AbortMessage("Asset writer failed.")
                                {
                                    Message in
                                    fatalError(Message)
                                }
                            }
                    }
                    )
            }
            )
        }
        catch
        {
            fatalError("Error creating asset writer.")
        }
    }
    
    /// Save the video at the passed URL to the photo roll.
    /// - Note: This function expects the URL's path to have a valid extension for the type of file, in our case, a valid
    ///         video extension (such as `.mp4`). **If the URL does not have a valid extension, this function will fail.**
    /// - Parameter SourceVideo: The URL of the video to save.
    /// - Parameter Completed: Completion handler. Called regardless of the success or failure of saving the video.
    public static func SaveVideoToPhotoRoll(SourceVideo: URL, Completed: ((Bool) -> ())? = nil)
    {
        PHPhotoLibrary.shared().performChanges(
            {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: SourceVideo)
        },
            completionHandler:
            {
                saved, error in
                if saved
                {
                    DispatchQueue.main.async
                        {
                            Completed?(true)
                    }
                }
                else
                {
                    print("Photo library error \((error?.localizedDescription)!)")
                    DispatchQueue.main.async
                        {
                            Completed?(false)
                    }
                }
        })
    }
}
