//
//  FlowWebViewController.swift
//  SWHY_Moblie
//
//  Created by sunny on 3/13/15.
//  Copyright (c) 2015 DY-INFO. All rights reserved.
//

import UIKit

@objc(FlowWebViewController) class FlowWebViewController: UIViewController,UIWebViewDelegate,NSURLConnectionDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    //let webView:UIWebView = UIWebView()
    var request:NSURLRequest = NSURLRequest()
    var authenticated:Bool = false
    var failure_auth = 0
    var urlstr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let webView:UIWebView = self.view.viewWithTag(10) as UIWebView
        //webView = UIWebView()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        webView.frame = self.view.frame
        webView.delegate = self
        self.view.addSubview(webView)
        
        
        urlstr = Message.shared.curMenuItem.uri
        let url:NSURL = NSURL(string: urlstr)!        
        
        
        print("did web load \(url)")
        request = NSURLRequest(URL: url)
        
        webView.loadRequest(request)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Message.shared.curMenuItem.name
        let backitem = UIBarButtonItem(title: Config.UI.PreNavItem, style: UIBarButtonItemStyle.Plain, target: self, action: "returnNavView")
        self.navigationItem.leftBarButtonItem = backitem
        
    }
    
    func returnNavView(){
        print("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidStartLoad(webView: UIWebView){
        print("did start load \(webView.request?.URL)")
        
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        print("didFailLoadWithError")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.WebViewPreGet, object: nil)
        print(self.urlstr)
        NetworkEngine.sharedInstance.addRequestWithUrlString(self.urlstr, tag: Config.RequestTag.WebViewPreGet,useCache:false)

    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if self.authenticated == false { 
            print("webview asking for permission to start loading  false")
            authenticated = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleNetworkResult:", name: Config.RequestTag.WebViewPreGet, object: nil)
            NetworkEngine.sharedInstance.addRequestWithUrlString(self.urlstr, tag: Config.RequestTag.WebViewPreGet,useCache:false)
            return false
        }
        print("webview asking for permission to start loading   true")
        
        return true
    }
    
    
    func HandleNetworkResult(notify:NSNotification)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Config.RequestTag.WebViewPreGet, object: nil)
        
        let result:Result = notify.valueForKey("object") as! Result
        print(result.status)
        if result.status == "Error" {
            PKNotification.toast(result.message)
        }else if result.status=="OK"{
            let url:NSURL = NSURL(string: urlstr)!
            request = NSURLRequest(URL: url)
            print(request.URL)
            self.authenticated = true
            webView.loadRequest(request)
            print("---load again------")
        }    
    }

    
}