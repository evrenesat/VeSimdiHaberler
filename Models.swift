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
    
}


class Kaynak: RLMObject {
    dynamic var isim = ""
    dynamic var url = ""
    dynamic var kategori = Kategori()
}


class Haber: RLMObject {
    dynamic var baslik = ""
    dynamic var ozet = ""
    dynamic var image = ""
    dynamic var url = ""
    dynamic var date = NSDate()
    dynamic var kaynak = Kaynak()
}
