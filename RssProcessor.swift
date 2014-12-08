//
//  RssReader.swift
//  rss4
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import Foundation
import Realm
import UIKit

class RSSProcessor: NSObject, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var elements = [String:String]()
    var feeds = [[String:String]]()
    var element = ""
    var ftitle = ""
    var image = ""
    var link = ""
    var fdescription = ""
    var caller = UITableViewController?()
    var kaynak = Kaynak()
    let realm = RLMRealm.defaultRealm()
    
    override init(){
        super.init()
        
        kaynak.isim = "NTV Teknoloji"
        kaynak.url = "http://www.ntvmsnbc.com/id/24927532/device/rss/rss.xml"
    }
    func startParsing(caller: UITableViewController) {
        
        feeds = []
        self.caller = caller
        var url = NSURL(string:"http://www.ntvmsnbc.com/id/24927532/device/rss/rss.xml")
        parser = NSXMLParser (contentsOfURL: url)!
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        parser.parse()
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        element = elementName
        println(elementName)
        if elementName == "item" {
            elements = [:]
            ftitle = ""
            link = ""
            image = ""
            fdescription = ""
        }
        
    }
    
    func getFirstImageUrl(html: String) -> String{
        // rss
        var result = ""
        let ld = NSDataDetector(types:NSTextCheckingType.Link.rawValue, error: nil)
        var matches = ld?.matchesInString(html, options: nil, range: NSMakeRange(0, countElements(html))) ?? []
        for m in matches{
            var url_string = m.URL??.absoluteString ?? ""
            if url_string.hasSuffix(".jpg") || url_string.hasSuffix(".png"){
                result = url_string
                break
            }
        }
        return result
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        
        if elementName == "item" {
            elements["title"] = ftitle
            elements["description"] = fdescription.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            elements["image"] = image
            elements["link"] = link
            feeds.append(elements)
            
            var haber = Haber()
            haber.url = link
            haber.image = getFirstImageUrl(fdescription)
            haber.baslik = ftitle
            haber.kaynak = kaynak
            haber.ozet = fdescription.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            realm.transactionWithBlock() {
                self.realm.addObject(haber)
            }

            
            
        }
        
        
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String!) {
        
        switch element{
        case "title":
            ftitle += string
        case "media:content":
            image += string
        case "link":
            link += string
        case "description":
            fdescription += string
        default:
            println(element)
            println(string)
            break
            
        }
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        self.caller?.tableView.reloadData()
        realm.transactionWithBlock() {
            self.realm.addObject(self.kaynak)
        }
    }
    
}

