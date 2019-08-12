//
//  QPViewController.swift
//  QuickPaySDK
//
//  Created on 12/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class QPPaymentWindowController: UIViewController {

    // MARK: - Enums
    
    private enum StateToken: String {
        case success = "success"
        case failure = "failure"
    }
    
    
    // MARK: - Callbacks
    
    var onCancel: (() -> Void)?
    var onResponse: ((Bool) -> Void)?
    
    
    // MARK: - Properties
    
    var gotoUrl: String?
    var webView: WKWebView?
    
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        webView!.navigationDelegate = self
        
        self.view.addSubview(webView!)

        if let gotoUrl = self.gotoUrl, let url = URL(string: gotoUrl) {
            webView!.load(URLRequest(url: url))
        }
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: {
            self.onCancel?()
        })
    }

    private func onWebViewRedirectToToken(token: StateToken) {
        dismiss(animated: true, completion: nil)
        
        if token == .success {
            onResponse?(true)
        }
        else {
            onResponse?(false)
        }
    }
}

extension QPPaymentWindowController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        if urlString.contains(StateToken.success.rawValue) {
            onWebViewRedirectToToken(token: .success)
            decisionHandler(.cancel);
        }
        else if urlString.contains(StateToken.failure.rawValue) {
            onWebViewRedirectToToken(token: .failure)
            decisionHandler(.cancel);
        }
        else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        QuickPay.logDelegate?.log("An error occured in QPPaymentWindowController, didFailNavigation: \nError: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        QuickPay.logDelegate?.log("An error occured in QPPaymentWindowController, didFailProvisionalNavigation: \nError: \(error.localizedDescription)")
    }
    
}
