//
//  HaberKaynaklariniGuncelle.swift
//  Ve Şimdi Haberler
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import Foundation
import Realm
import UIKit

//let UYGULAMA_SUNUCUSU = "http://mobil-iz.org/swift-data/api/"
let UYGULAMA_SUNUCUSU = "http://evrenes.at/mobiliz/"
//let UYGULAMA_SUNUCUSU = "http://localhost:8000/"
let HABER_ONBELLEK_SURESI = 2 // gun

class HaberKaynaklariniGuncelle{

    var kategoriEkrani:KategoriViewController?
    let dosyaYoneticisi = NSFileManager.defaultManager(),
        dokumanlarDiziniYolu = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    
    
    init(kategoriEkrani: KategoriViewController?){
        eskiHaberleriSil()
        self.kategoriEkrani = kategoriEkrani
        let url = NSURL(string: "\(UYGULAMA_SUNUCUSU)kaynaklar.json")!
        NSURLSession.sharedSession().dataTaskWithURL(url, veriIsle).resume()

    }
    
    func eskiHaberleriSil(){
        let realm = RLMRealm.defaultRealm(),
            tarih = NSDate(timeIntervalSinceNow: -Double(60 * 60 * 24 * HABER_ONBELLEK_SURESI))
        let eskiHaberler = Haber.objectsWhere("tarih < %@ and favori=false", tarih)
        realm.transactionWithBlock() {
            realm.deleteObjects(eskiHaberler)
        }
    }
    
    
    func veriIsle(kaynak: NSData!, response: NSURLResponse!, error: NSError!){
        /*
            json verisini satır satır işleyerek kategori ve haber kaynaklarını
            veritabanına kayediyor ve ardindan kategori görsellerini indiriyoruz.
            son olarak kategori ekranini yeniliyoruz
        
            Kategori nesnemizi, Realm'in createOrUpdateInDefaultRealmWithObject metoduna JSON sözlüğünü vererek oluşturuyoruz.
           */
        
        
        let realm = RLMRealm.defaultRealm()
        if let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(kaynak,
            options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary{
                for kategori in jsonResult["kategoriler"] as [NSDictionary]{
                    realm.transactionWithBlock() {
                        var kategoriVarmi = Kategori.objectsWhere("isim = %@", kategori["isim"] as String)
                        var kategoriSecilimi = kategoriVarmi.count > 0 ? (kategoriVarmi.firstObject() as Kategori).secili : false
                        var dbkategori = Kategori.createOrUpdateInDefaultRealmWithObject(kategori)
                        dbkategori.secili = kategoriSecilimi
                        for kaynak in kategori["kaynak"] as [NSMutableDictionary]{
                            kaynak["kategori"] = dbkategori
                            Kaynak.createOrUpdateInDefaultRealmWithObject(kaynak)
                        }
                    }
                    self.gorseliIndir(kategori["gorsel"] as String)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.kategoriEkrani?.kategoriEkraniniYenile()
                    return
                }
        }
    }
    
    func gorseliKaydet(dosya_path: String, yol: String){
        
        // gecici dizine indirdigimiz gorseli uygulamamizin Document dizinine kopyaliyoruz.
        // her bir gorselin basariyla kopyalanmasindan sonra kategori ekranini yeniliyoruz
        
        if (dosyaYoneticisi.copyItemAtPath(yol, toPath:dosya_path, error:nil)) {
            
            println("Dosya basariyla kaydedildi")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.kategoriEkrani?.kategoriEkraniniYenile()
                return
            }
            
        }else {
            println("Dosya kaydedilemedi!")
        }
        
    }
    
    func gorseliIndir(image_name: String){
        
        // gorsel Document dizinimizde zaten mevcut degilse, sunucudan indiriyoruz.
        
        var dosya_path = dokumanlarDiziniYolu.stringByAppendingPathComponent(image_name)
        if(!dosyaYoneticisi.fileExistsAtPath(dosya_path)) {
            
            let url = NSURL(string: "\(UYGULAMA_SUNUCUSU)images/\(image_name)")!
            NSURLSession.sharedSession().downloadTaskWithURL(url, {
                (yol, response, error) in
                self.gorseliKaydet(dosya_path, yol: yol.path!)
                
            }).resume()
        }
        
    }
    
    

    

}