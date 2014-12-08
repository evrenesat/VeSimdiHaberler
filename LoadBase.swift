//
//  LoadBase.swift
//  rss4
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import Foundation
import Realm

class LoadBaseData{

    var current_category_image = "",
        dbkategori: Kategori!
    
    let host = "http://localhost:8000/",
        theFileManager = NSFileManager.defaultManager(),
        doc_dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

  
    init(){
        let url = NSURL(string: "\(host)kaynaklar.json")!
        NSURLSession.sharedSession().dataTaskWithURL(url, veriIsle).resume()
        println(RLMRealm.defaultRealm().path)
        
        println(RLMRealm.defaultRealm().path)
    }
    
    
    func veriIsle(kaynak: NSData!, response: NSURLResponse!, error: NSError!){
        // json verisini satır satır işleyerek kategori ve haber kaynaklarını 
        // veritabanına kayediyor ve kategori görsellerini indiriyoruz.
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(kaynak,
            options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        for kategori in jsonResult["kategoriler"] as NSArray{
            self.kategorileriOlustur(kategori as NSDictionary)
            self.kaynaklariOlustur(kategori as NSDictionary)
            self.gorseliNdir(kategori["gorsel"] as String)
            
            
        }
        
    }
    
    func kaynaklariOlustur(katdict: NSDictionary) {
        // veritabaninda yoksa json haber nesnesinden, haber kaydi olusturuyoruz
        let realm = RLMRealm.defaultRealm()
        for kaynak:Dictionary<String, AnyObject> in katdict["kaynaklar"] as Array{
            var isim = kaynak["ad"] as String,
                url = kaynak["url"] as String
            if Kaynak.objectsWhere("isim = '\(isim)'").count == 0{
                let dbkaynak = Kaynak()
                dbkaynak.isim = isim
                dbkaynak.url = url
                dbkaynak.kategori = dbkategori
                realm.transactionWithBlock() {
                    realm.addObject(dbkaynak)
                }
            }
        }
    }
    
    func kategorileriOlustur(katdict: NSDictionary) {
        // veritabaninda varsa mevcut kaydi varsa alıyoruz,
        // yoksa json nesnesindeki kategori bilgisine gore yeni dbkategori kaydi olusup,
        // self.dbkategori uzerine atıyoruz.
        let realm = RLMRealm.defaultRealm(),
            isim = katdict["ad"] as String,
            gorsel = katdict["gorsel"] as String,
            kategori_set = Kategori.objectsWhere("isim = '\(isim)'")
        if kategori_set.count > 0{
            dbkategori = kategori_set.firstObject() as Kategori
        }else{
            dbkategori = Kategori()
            dbkategori.gorsel = gorsel
            dbkategori.isim = isim
            realm.transactionWithBlock() {
                realm.addObject(self.dbkategori)
            }
        }
    }
    
    func gorseliKaydet(dosya_path: String, yol: String){
        // gecici dizine indirdigimiz gorseli uygulamamizin Document dizinine kopyaliyoruz.
        if (theFileManager.copyItemAtPath(yol, toPath:dosya_path, error:nil)) {
            println("Dosya basariyla kaydedildi")
        }else {
            println("Dosya kaydedilemedi!")
        }
    }
    
    func gorseliNdir(image_name: String){
        // gorsel Document dizinimizde zaten mevcut degilse, sunucudan indiriyoruz.
        var dosya_path = doc_dir.stringByAppendingPathComponent(image_name + ".png")
        if(!theFileManager.fileExistsAtPath(dosya_path)) {
            let url = NSURL(string: "\(host)images/\(image_name).png")!
            NSURLSession.sharedSession().downloadTaskWithURL(url, {
                (yol, response, error) in
                self.gorseliKaydet(dosya_path, yol: yol.path!)
                
            }).resume()
        }
        
    }
    

}