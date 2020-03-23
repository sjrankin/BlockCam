//
//  HelpViewController2.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class HelpViewController2: UIViewController, WKUIDelegate, WKNavigationDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ActivityView.isHidden = false
        HelpOutput.uiDelegate = self
        self.title = ControllerTitle
        if let FinalHTML = HTML
        {
            HelpOutput.loadHTMLString(FinalHTML, baseURL: nil)
        }
    }
    
    public var ControllerTitle: String = "Help Viewer"
    
    public var HTML: String? = nil
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        ActivityView.isHidden = true
    }
    
    @IBOutlet weak var ActivityView: UIActivityIndicatorView!
    @IBOutlet weak var HelpOutput: WKWebView!
}
