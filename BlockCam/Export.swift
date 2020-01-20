//
//  Export.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: UIActivityItemSource
{
    /// Export the passed image.
    /// - Parameter Image: The image to export.
    func DoExportImage(_ Image: UIImage)
    {
        ImageToExport = Image
        let Items: [Any] = [self]
        let ACV = UIActivityViewController(activityItems: Items, applicationActivities: nil)
        ACV.popoverPresentationController?.sourceView = self.view
        ACV.popoverPresentationController?.sourceRect = self.view.frame
        ACV.popoverPresentationController?.canOverlapSourceViewRect = true
        ACV.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        self.present(ACV, animated: true, completion: nil)
    }
    
    /// Returns the subject line for possible use when exporting the gradient image.
    /// - Parameter activityViewController: Not used.
    /// - Parameter subjectForActivityType: Not used.
    /// - Returns: Subject line.
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.Type?) -> String
    {
        return "BlockCam Image"
    }
    
    /// Determines the type of object to export.
    /// - Parameter activityViewController: Not used.
    /// - Returns: Instance of the type to export. In our case, a `UIImage`.
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any
    {
        return UIImage()
    }
    
    /// Returns the object to export (the type of which is determined in `activityViewControllerPlaceholderItem`.
    /// - Parameter activityViewController: Not used.
    /// - Parameter itemForActivityType: Determines how the user wants to export the image. In our case, we support
    ///                                  anything that accepts an image.
    /// - Returns: The image of the gradient.
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any?
    {
        let Generated: UIImage = ImageToExport!
        
        switch activityType!
        {
            case .postToTwitter:
                return Generated
            
            case .airDrop:
                return Generated
            
            case .copyToPasteboard:
                return Generated
            
            case .mail:
                return Generated
            
            case .message:
                return Generated
            
            case .postToFacebook:
                return Generated
            
            case .postToFlickr:
                return Generated
            
            case .postToTencentWeibo:
                return Generated
            
            case .postToTwitter:
                return Generated
            
            case .postToWeibo:
                return Generated
            
            case .print:
                return Generated
            
            case .markupAsPDF:
                return Generated
            
            case .saveToCameraRoll:
                return Generated
            
            default:
                return Generated
        }
    }
}
