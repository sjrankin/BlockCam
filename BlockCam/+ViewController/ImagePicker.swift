//
//  ImagePicker.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage
import AVKit
import CoreServices
import MobileCoreServices

extension ViewController
{
    // MARK: - UIImagePickerControllerDelegate functions.
    
    /// Image picker canceled by the user. We only care about this because if we didn't, the image picker would never
    /// disappear - we have to close it manually.
    /// - Parameter picker: Not used.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        InitialProcessedImage = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Image picker finished picking a media object notice.
    /// - Note: We only care about still images and videos. Each is processed through a different code path but ultimate the same
    ///         code generates the resultant image/video.
    /// - Parameter picker: Not used.
    /// - Parameter didFinishPickingMediaWithInfo: Information about the selected image/media.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        SwitchToImageMode()
        ShowStatusLayer()
        self.dismiss(animated: true, completion: nil)
        let MediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        switch MediaType
        {
            case kUTTypeMovie:
                if let VideoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                {
                    OutputView.Clear()
                    BackgroundThread.async
                        {
                            self.OutputView.ProcessVideo(VideoURL)
                    }
            }
            
            case kUTTypeImage:
                if let SelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
                {
                    ShowStatusLayer()
                    CurrentViewMode = .ProcessedView
                    ShowMessage("Please Wait", TextColor: UIColor.black, StrokeColor: UIColor.systemYellow)
                    ImageToProcess = SelectedImage
                    OutputView.Clear()
                    BackgroundThread.async
                        {
                            self.OutputView.ProcessImage(self.ImageToProcess!)
                    }
            }
            
            default:
                Crash.ShowCrashAlert(WithController: self, "Error", "Unexpected image type \(MediaType) encountered.")
                Log.AbortMessage("Unexpected image type (\(MediaType)) encountered.")
                {
                    Message in
                    fatalError(Message)
            }
        }
    }
}
