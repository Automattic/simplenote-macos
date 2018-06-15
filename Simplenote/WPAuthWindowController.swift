//
//  WPAuthViewController.swift
//  Simplenote
//

import Cocoa
import WebKit

class WPAuthWindowController: NSWindowController {
    
    @IBOutlet var webView: WebView!
    
    @objc public func loadUrl(url: URL) {
        webView.mainFrame.load(URLRequest(url: url))
    }
}
