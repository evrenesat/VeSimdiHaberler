//
//  PostViewController.swift
//  VeSimdiHaberler
//
//  Created by Evren Esat Ozkan on 05/12/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm

class PostViewController: UIViewController, UIWebViewDelegate {
    
//    @IBOutlet var webView: UIWebView!
//    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView!
//    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var webView: UIWebView!
    var haber: Haber!
    let realm = RLMRealm.defaultRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = haber.kaynak.isim
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .Bookmarks,  target: self, action: "haberiFavorilereEkle"),
            UIBarButtonItem(barButtonSystemItem: .Action,  target: self, action: "shareSheet")]
        
        webView.delegate = self
        let url: NSURL = NSURL(string: haber.url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))!
        println("postlink :|\(url.standardizedURL)|")
        let request = NSURLRequest(URL: url) as NSURLRequest
        webView.loadRequest(request)

    }
    
    func shareSheet(){
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [ NSURL(fileURLWithPath: haber.url)!], applicationActivities: nil)
    
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func haberiFavorilereEkle(){
        realm.transactionWithBlock() {
            self.haber.favori = self.haber.favori == true ? false : true
        }
        var mesaj = self.haber.favori ? "Favorilere Eklendi" : "Favorilerinizden Çıkarıldı"
        var alert = UIAlertController(title: mesaj, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    func webViewDidFinishLoad(webView: UIWebView!) {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
