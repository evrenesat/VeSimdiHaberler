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

class RSSIsleyici: NSObject, NSXMLParserDelegate {
    
    let parser = NSXMLParser(),
        realm = RLMRealm.defaultRealm()
    var         element = "",
        ftitle = "",
        image = "",
        link = "",
        fdescription = "",
    suankiOgeOzellikleri: NSDictionary!,
        kaynak_url = "",
        kaynak: Kaynak!

    init(kurl: String){
        super.init()
        kaynak_url = kurl
        kaynak = Kaynak.objectsWhere("url = %@", kaynak_url).firstObject() as Kaynak
        parser = NSXMLParser (contentsOfURL: NSURL(string:kaynak_url))!
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        parser.parse()
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        element = elementName
        if elementName == "item" {
            ftitle = ""
            link = ""
            image = ""
            fdescription = ""
        }
        if elementName.hasPrefix("media:") && image == ""{
            image = ilkBuldugunGorseliAl(attributeDict.description)
        }
    }
    
    func ilkBuldugunGorseliAl(html: String) -> String{
        // Bu metod verilen metin içerisinde sonu jpg yada png ile biten ilk URLyi geri döndürür.
        // Bazı haber kaynakları haber görsellerini media etiketi altına koymak yerine
        // description alanının içine koymayı tercih(!) ediyorlar
        // haberimizin bir görseli olsun diye elimizden geleni yapıyoruz.
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
        let haberimiz_yok = Haber.objectsWhere("url = %@", link).count == 0
        if elementName == "item" && haberimiz_yok {
            var haber = Haber()
            haber.url = link
            haber.gorselurl =  image != "" ? image : ilkBuldugunGorseliAl(fdescription)
            haber.baslik = ftitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
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
        case "link":
            link += string
        case "description":
            fdescription += string
        default:
            break
        }
    }
}



class haberleriGuncelle {
    // uygulama acilisinda cagrilir. tum secili kategorilerdeki tum kaynaklari gunceller.
    let kategori_set = Kategori.objectsWhere("secili==true"),
    realm = RLMRealm.defaultRealm(),
    xmlCozumleyiciKuyrugu = dispatch_queue_create("xmlCozumleyiciKuyrugu", DISPATCH_QUEUE_SERIAL)
    
    init(){
        
        var seciliKategoriSayisi = Int(kategori_set.count)
        
        for i in 0 ..< seciliKategoriSayisi {
            var kategori = kategori_set.objectAtIndex(UInt(i)) as Kategori
            var seciliKategoridekiKaynaklar = kategori.kaynaklar
            for k in 0..<seciliKategoridekiKaynaklar.count{
                var kaynak_url = seciliKategoridekiKaynaklar[k].url
                
                dispatch_async(xmlCozumleyiciKuyrugu){
                    RSSIsleyici(kurl: kaynak_url)
                    return
                }
            }
        }
        
    }
}

class kategoriGuncelle {
    // secili kategori menuden cagirildiginda cagirilir.
    let xmlCozumleyiciKuyrugu = dispatch_queue_create("xmlCozumleyiciKuyrugu", DISPATCH_QUEUE_SERIAL)
    init(kategori: Kategori){
        for k in 0..<kategori.kaynaklar.count{
            var url = kategori.kaynaklar[k].url
            dispatch_async(xmlCozumleyiciKuyrugu){
                RSSIsleyici(kurl: url)
                return
            }
        }
    }
}