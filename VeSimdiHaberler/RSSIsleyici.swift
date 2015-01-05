//
//  RSSIsleyici.swift
//  VeSimdiHaberler
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import Foundation
import Realm
import UIKit

class RSSIsleyici: NSObject, NSXMLParserDelegate {
    //
    // bu sinif URL'si verilen RSS haber kayanigini ceker, cozumler, veritabaninda olmayan haberleri kaydeder.
    //
    let parserOpt: NSXMLParser!,
    realm = RLMRealm.defaultRealm()
    var element = "",
    haberBasligi = "",
    image = "",
    haberURL = "",
    haberOzet = "",
    suankiOgeOzellikleri: NSDictionary!,
    kaynak: Kaynak!
    
    init(kaynakURL: String){
        super.init()
        // veri tabanindan ilgili haber kaynagi kaydini aliyoruz
        kaynak = Kaynak.objectsWhere("url = %@", kaynakURL).firstObject() as Kaynak
        // xmlparser nesnesini haber kaynaginin URLsi ile ilklendiriyoruz
//        println(kaynakURL)
        let parserOpt : NSXMLParser! = NSXMLParser(contentsOfURL: NSURL(string:kaynakURL))
        if let parser = parserOpt{
        // kendimizi xml parserin delegesi olarak atiyoruz
        parser.delegate = self
        // xml parserla ilgili gerekli ayarlari yapiyoruz
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        // xml dosyasini indirip cozumleme islemini baslatiyoruz
        parser.parse()
        }
//        else{
//            println("cant connect")
//        }
//        
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
        
        // cozumleyici bir xml elementinin sonuna geldiginde bu metodu cagirir
        // sonuna gelinen elementin adi "item" ise, haberle ilgili almamiz gereken tum verileri aldigimizi anliyoruz
        // eger bu haberi daha once kaydetmediysek yani haberimizYoksa yeni bir Haber kaydi olusturuyoruz.
        
        let haberimizYok = Haber.objectsWhere("url = %@", haberURL).count == 0
        if elementName == "item" && haberimizYok {
            var haber = Haber()
            haber.url = haberURL
            haber.gorselurl =  image != "" ? image : ilkBuldugunGorseliAl(haberOzet)
            haber.baslik = haberBasligi.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            haber.kaynak = kaynak
            haber.ozet = haberOzet.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            realm.transactionWithBlock() {
                self.realm.addObject(haber)
            }
        }
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String!) {
        // o anda islenmekte olan xml elementi eger ilgilendiklerimizden biriysse,
        // parserin buldugu karakterleri o oge icin olsuturdugumuz degisken icerisinde sakliyoruz
        switch element{
        case "title":
            haberBasligi += string
        case "link":
            haberURL += string
        case "description":
            haberOzet += string
        default:
            break
        }
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        // bu metod xml parser tarafindan her elementi islemeye baslarken cagrilir
        // elementten degerlerini sakladigimiz degiskenlerde onceki elementlerden kalan degerleri temizliyoruz
        // eger elemnt "media:" ile basliyorsa ilkBuldugunGorseliAl metoduyla haberin gorselini
        
        element = elementName
        if elementName == "item" {
            haberBasligi = ""
            haberURL = ""
            image = ""
            haberOzet = ""
        }
        if elementName.hasPrefix("media:") && image == ""{
            image = ilkBuldugunGorseliAl(attributeDict.description)
        }
    }
    
}




class haberleriGuncelle {
    let kategoriler = Kategori.objectsWhere("secili = true")
    init(){
        for i in 0 ..< Int(kategoriler.count) {
            var kategori = kategoriler.objectAtIndex(UInt(i)) as Kategori
            kategoriGuncelle(kategori: kategori)
        }
    }
}

class kategoriGuncelle{
    init(kategori: Kategori){
        for kaynak in kategori.kaynaklar{
            var kaynakURL = kaynak.url
            let reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(reentrantAvoidanceQueue){
//                sleep(1)
                RSSIsleyici(kaynakURL: kaynakURL)
                return
            }
        }
    }
}