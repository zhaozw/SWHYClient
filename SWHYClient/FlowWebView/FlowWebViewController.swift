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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let webView:UIWebView = self.view.viewWithTag(10) as UIWebView
        //webView = UIWebView()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        webView.frame = self.view.frame
        webView.delegate = self
        self.view.addSubview(webView)
        var url:NSURL = NSURL(string: Config.URL.ToDoList)!
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
        println("click return button")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        println("didFailLoadWithError")
        //NetworkEngine.sharedInstance.addRequestWithUrlString(Config.URL.ToDoList, tag: "")
    }
    func webViewDidStartLoad(webView: UIWebView){
        println("did start load")
    }
    
}


