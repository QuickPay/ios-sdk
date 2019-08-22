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

public protocol QPPaymentWindowControllerDelegate {
    func onPaymentResponse(success: Bool)
    func onPaymentCancelled()
    
    func populateLoadingView(loadingView: UIView)
    func loadingProgress(estimatedLoadingProgress: Float)
}

class QPPaymentWindowControllerDelegateCallbacksWrapper: QPPaymentWindowControllerDelegate {
    var onCancel: (() -> Void)?
    var onResponse: ((Bool) -> Void)?

    func onPaymentResponse(success: Bool) {
        onResponse?(success)
    }
    
    func onPaymentCancelled() {
        onCancel?()
    }
    
    func populateLoadingView(loadingView: UIView) {
        let ai = UIActivityIndicatorView.init(style: .gray)
        ai.startAnimating()
        ai.center = loadingView.center
        
        loadingView.addSubview(ai)
    }
    
    func loadingProgress(estimatedLoadingProgress: Float) {
        
    }
}

public class QPPaymentWindowController: UIViewController {

    // MARK: - Enums
    
    private enum StateToken: String {
        case success = "success"
        case failure = "failure"
    }
    
    
    // MARK: - Delegates
    
    public var delegate: QPPaymentWindowControllerDelegate?
    
    
    // MARK: - Properties
    
    private let estimatedProgressKey = "estimatedProgress"
    private var paymentUrl: String
    private var loadingView: UIView?
    
    
    // MARK: - Init
    
    public required init(paymentUrl: String) {
        self.paymentUrl = paymentUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.paymentUrl = ""
        super.init(coder: aDecoder)
    }
    
    public convenience init(paymentUrl: String, delegate: QPPaymentWindowControllerDelegate ) {
        self.init(paymentUrl: paymentUrl)
        self.delegate = delegate
    }

    public convenience init(paymentUrl: String, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void) {
        self.init(paymentUrl: paymentUrl)
        
        let delegateWrapper = QPPaymentWindowControllerDelegateCallbacksWrapper()
        delegateWrapper.onCancel = onCancel
        delegateWrapper.onResponse = onResponse
        self.delegate = delegateWrapper
    }
    
    
    // MARK: - Lifecycle
    
    public override func loadView() {
        super.loadView()
        
        self.view = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        if let webView = self.view as? WKWebView, let url = URL(string: paymentUrl) {
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.load(URLRequest(url: url))
            
            webView.addObserver(self, forKeyPath: estimatedProgressKey, options: .new, context: nil)
        }
        
        loadingView = UIView(frame: self.view.bounds)
        if let loadingView = loadingView {
            loadingView.backgroundColor = UIColor.white
            delegate?.populateLoadingView(loadingView: loadingView)
            self.view.addSubview(loadingView)
        }
    }
    
    @objc public func cancel() {
        delegate?.onPaymentCancelled()
    }

    private func onWebViewRedirectToToken(token: StateToken) {
        dismiss(animated: true, completion: nil)
        
        if token == .success {
            delegate?.onPaymentResponse(success: true)
        }
        else {
            delegate?.onPaymentResponse(success: false)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == estimatedProgressKey, loadingView != nil, let webView = self.view as? WKWebView {
            delegate?.loadingProgress(estimatedLoadingProgress: Float(webView.estimatedProgress))
        }
    }
}

extension QPPaymentWindowController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        QuickPay.logDelegate?.log("An error occured in QPPaymentWindowController, didFailNavigation: \nError: \(error.localizedDescription)")
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        QuickPay.logDelegate?.log("An error occured in QPPaymentWindowController, didFailProvisionalNavigation: \nError: \(error.localizedDescription)")
    }
    
}

extension QPPaymentWindowController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let ac = UIAlertController(title: "", message: message, preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            completionHandler(true)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            completionHandler(false)
        }))

        present(ac, animated: true)
    }

//    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
//
//    }
//
//    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//
//    }
    
}
