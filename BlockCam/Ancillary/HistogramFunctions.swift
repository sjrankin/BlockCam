//
//  HistogramFunctions.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension ViewController
{
    ///Initialize the histogram view then hide it.
    /// - Note: sett [Round specific corners of view.](https://www.hackingwithswift.com/example-code/calayer/how-to-round-only-specific-corners-using-maskedcorners)
    func InitializeHistogramView()
    {
        HistogramIsVisible = false
        HistogramView.alpha = 0.0
        HistogramView.layer.zPosition = -1000
        HistogramView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        HistogramView.layer.borderWidth = 1.0
        HistogramView.layer.cornerRadius = 5.0
        HistogramView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        HistogramView.isUserInteractionEnabled = false
        let Idiom = UIDevice.current.userInterfaceIdiom
        let FinalWidth: CGFloat = Idiom == .phone ? view.frame.width : view.frame.width / 2.0
        HistogramView.layer.maskedCorners = Idiom == .phone ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMaxXMaxYCorner]
        HistogramView.frame = CGRect(x: 0, y: 20,
                                     width: FinalWidth,
                                     height: HistogramView.frame.height)
    }
    
    /// Populate the histogram display with the passed histogram data.
    func PopulateHistogram(_ HData: Histogram, InView: UIView)
    {
        let ViewWidth: CGFloat = InView.frame.width
        let ViewHeight: CGFloat = InView.frame.height
        print("\(HData.MaxRed()),\(HData.MaxGreen()),\(HData.MaxBlue())")
    }
    
    /// How the histogram view.
    func ShowHistogramView()
    {
        HistogramView.layer.zPosition = 1000
        UIView.animate(withDuration: 0.35,
                       animations:
            {
                self.HistogramView.alpha = 1.0
        }, completion:
            {
                _ in
                self.HistogramIsVisible = true
        })
    }
    
    /// Hide the histogram view.
    func HideHistogramView()
    {
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.HistogramView.alpha = 0.0
        }, completion:
            {
                _ in
                self.HistogramView.layer.zPosition = -1000
                self.HistogramIsVisible = false
        })
    }
}
