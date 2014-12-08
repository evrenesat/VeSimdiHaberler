//
//  models.swift
//  rss4
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import Foundation
import Realm

class Kategori: RLMObject {
    dynamic var gorsel = ""
    dynamic var isim = ""
    dynamic var secili = false
    dynamic var id = ""
    
    var kaynaklar: [Kaynak] {
        return linkingObjectsOfClass("Kaynak", forProperty: "kategori") as [Kaynak]
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}


class Kaynak: RLMObject {
    dynamic var isim = ""
    dynamic var url = ""
    dynamic var kategori = Kategori()
    dynamic var id = ""
    
    var haberler: [Haber] {
        return linkingObjectsOfClass("Haber", forProperty: "kaynak") as [Haber]
    }
    
    
    override class func primaryKey() -> String! {
        return "id"
    }
}


class Haber: RLMObject {
    dynamic var baslik = ""
    dynamic var ozet = ""
    dynamic var gorselurl = ""
    dynamic var gorsel = ""
    dynamic var url = ""
    dynamic var favori = false
    dynamic var tarih = NSDate()
    dynamic var kaynak = Kaynak()
    
    override class func primaryKey() -> String! {
        return "url"
    }
    
}
