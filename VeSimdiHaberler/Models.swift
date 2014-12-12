//
//  Models.swift
//  Ve Şimdi Haberler
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
/*
 
Bu dosya uygulamamızda kullanacağımız veritabanı modellerimizi oluşturuyoruz.
Bunun için Apple'ın Core Data'sı yerine http://realm.io adresinden ücretsiz  olarak edinilebilecek Realm kütüphanesini kullanıyoruz.
Realm ile veritabanı işlemleri yapmak Core Data'dan daha hızlı ve kolay. Üstelik Android desteği
sayesinde aynı API ve veritabanı dosyasını uygulamamızın Andorid sürümünü hazırlarken de kullanabiliyoruz.
Realm doğrudan mobil uygulamalar ve nesneler düşünülerek hazırlandığı için alışık olduğumuz veritabanı
ve ORM paradigmalarına takılmadan, dilediğimiz zaman kalıcı hale getirebildiğimiz nesnelerle çalıştığımızı
varsayarak uygulamamızı kodlarsak Realm'in sunduğu avantajlardan daha iyi yararlanabiliriz.

*/

import Foundation
import Realm



class Kategori: RLMObject {
    /*
    Veri modellerimizi RLMObject dosyasının altsınıfı olarak tanımlıyoruz.
    Modelin özelliklerini (tablo alanları) "dynamic" olarak işaretli değişkenler olarak tanımlamamız yeterli.
    
    */
    dynamic var gorsel = ""
    dynamic var isim = ""
    dynamic var secili = false
    dynamic var id = ""
    
    var kaynaklar: [Kaynak] {
    /* 
        Belirli bir kategoriye ait haber kaynaklarına uygulama içinde sık sık ihtiyaç duyacağız,
        bu yüzden Kategor.kaynaklar şeklinde bir ters bağıntı oluşturuyouz. (inverse relation)
        
     */
        return linkingObjectsOfClass("Kaynak", forProperty: "kategori") as [Kaynak]
    }
    
    override class func primaryKey() -> String! {
      /*
        Uygulama içinde doğrudan kullanmasak da, verileri ilklendirme ve güncellemeyi oldukça kolaylaştıran 
        createOrUpdateInDefaultRealmWithObject metodunu kullanabilmek için tablomuzun birincil anahtarını
        tanımlıyoruz.
        */
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
