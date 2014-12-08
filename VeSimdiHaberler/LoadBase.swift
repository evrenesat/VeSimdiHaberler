//
//  LoadBase.swift
//  rss4
//
//  Created by Evren Esat Ozkan on 21/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import Foundation
import Realm
import UIKit

class loadBaseData{

    var kategoriEkrani:KategoriViewController?
    let host = "http://localhost:8000/",
        dosyaYoneticisi = NSFileManager.defaultManager(),
        dokumanlarDiziniYolu = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    
    
    init(uiv: KategoriViewController?){
        self.kategoriEkrani = uiv

        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "\(host)kaynaklar.json")!, veriIsle).resume()
    }
    
    
    func veriIsle(kaynak: NSData!, response: NSURLResponse!, error: NSError!){
        // json verisini satır satır işleyerek kategori ve haber kaynaklarını
        // veritabanına kayediyor ve kategori görsellerini indiriyoruz.
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
                    self.kategoriEkrani?.reloadData()
                    return
                }
        }
    }
    
    func gorseliKaydet(dosya_path: String, yol: String){
        // gecici dizine indirdigimiz gorseli uygulamamizin Document dizinine kopyaliyoruz.
        if (dosyaYoneticisi.copyItemAtPath(yol, toPath:dosya_path, error:nil)) {
            println("Dosya basariyla kaydedildi")
            dispatch_async(dispatch_get_main_queue()) {
                self.kategoriEkrani?.reloadData()
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
            let url = NSURL(string: "\(host)images/\(image_name)")!
            NSURLSession.sharedSession().downloadTaskWithURL(url, {
                (yol, response, error) in
                self.gorseliKaydet(dosya_path, yol: yol.path!)
                
            }).resume()
        }
        
    }
    
    

    

}