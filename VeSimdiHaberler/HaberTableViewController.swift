//
//  HaberTableViewController.swift
//  Ve Simdi Haberler
//
//  Created by Evren Esat Ozkan on 30/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm

class HaberTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var aramaKutusu: UISearchBar!
    var seciliKategori = "",
    bolumBasliklari: [String] = [],
    bolumSayisi = 0,
    gosterilecekHaberler: [String:Haber] = [:],
    bolumdekiHaberSayisi: [Int:Int] = [:]
    
    let dokumanlarDiziniYolu = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString,
    dosyaYoneticisi = NSFileManager.defaultManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aramaKutusu.delegate = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .Plain, target: self.navigationController?.sideMenuController()?.sideMenu, action: "toggleMenu")
        
        switch seciliKategori{
        case "":
            haberOzetleriniGoster()
            aramaKutusu.frame = CGRectMake(0,0,0,0)
        case "Favoriler":
            self.favorileriGoster()
        default:
            seciliKategoridekiHaberleriGoster()
        }
        
        self.title = seciliKategori != "" ? seciliKategori: "Ve Şimdi Haberler"
        haberGorselleriniIndir()
        
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var haber = gosterilecekHaberler["\(indexPath.section).\(indexPath.row)"]!,
        hucre: UITableViewCell!
        if haber.gorsel != "" {
            hucre = tableView.dequeueReusableCellWithIdentifier("gorselliHucre", forIndexPath: indexPath) as UITableViewCell
            hucre.indentationLevel  = 3
            hucre.indentationWidth = 20
            let iview = UIImageView(image: UIImage(contentsOfFile:"\(dokumanlarDiziniYolu)/\(haber.gorsel)"))
            iview.frame = CGRectMake(4, 4, 50, 50)
            hucre.contentView.addSubview(iview)
        }else{
            hucre = tableView.dequeueReusableCellWithIdentifier("Hucre", forIndexPath: indexPath) as UITableViewCell
        }
        hucre.textLabel?.text = haber.baslik
        hucre.detailTextLabel?.text = haber.ozet
        return hucre
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return bolumSayisi
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bolumdekiHaberSayisi[section]!
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return bolumBasliklari[section]
    }
    
    
    
    func seciliKategoridekiHaberleriGoster(){
        gosterilecekHaberler = [:]
        let kategori = Kategori.objectsWhere("isim = %@", seciliKategori).firstObject() as Kategori
        bolumSayisi = kategori.kaynaklar.count
        for kid in 0 ..< bolumSayisi {
            var kaynak = kategori.kaynaklar[kid]
            bolumBasliklari.append(kaynak.isim)
            let haberler = Haber.objectsWhere("kaynak = %@", kaynak).sortedResultsUsingProperty("tarih", ascending: true)
            bolumdekiHaberSayisi[kid] = Int(haberler.count > 10 ? 10 : haberler.count)
            
            for hid in 0 ..< bolumdekiHaberSayisi[kid]!{
                gosterilecekHaberler["\(kid).\(hid)"] =  haberler.objectAtIndex(UInt(hid)) as? Haber
            }
        }
    }

    
    func haberOzetleriniGoster(){
        gosterilecekHaberler = [:]
        let seciliKategoriler = Kategori.objectsWhere("secili = true")
        bolumSayisi = Int(seciliKategoriler.count)
        
        for katID in 0 ..< seciliKategoriler.count{
            var ikatID = Int(katID)
            var kategori = seciliKategoriler.objectAtIndex(katID) as Kategori
            bolumBasliklari.append(kategori.isim)
            bolumdekiHaberSayisi[ikatID] = 0
            
            for kaynakID in 0 ..< kategori.kaynaklar.count {
                var kaynak = kategori.kaynaklar[kaynakID]
                let haberler = Haber.objectsWhere("kaynak = %@", kaynak).sortedResultsUsingProperty("tarih", ascending: true)
                
                for hid in 0 ..< Int(haberler.count > 4 ? 4 : haberler.count){
                    bolumdekiHaberSayisi[ikatID]! += 1
                    gosterilecekHaberler["\(ikatID).\(bolumdekiHaberSayisi[ikatID]! - 1)"] = haberler.objectAtIndex(UInt(hid)) as? Haber
                }
            }
        }
    }
    
    func favorileriGoster(){
        gosterilecekHaberler = [:]
        bolumSayisi = 1
        var haberler = Haber.objectsWhere("favori = true").sortedResultsUsingProperty("tarih", ascending: true)
        if aramaKutusu.text != ""{
            haberler = haberler.objectsWithPredicate(NSCompoundPredicate.andPredicateWithSubpredicates(
                [NSPredicate(format:"baslik CONTAINS[c] %@ or ozet CONTAINS[c] %@", aramaKutusu.text, aramaKutusu.text)!]))
        }
        
        for hid in 0 ..< haberler.count{
            gosterilecekHaberler["0.\(hid)"] =  (haberler.objectAtIndex(UInt(hid)) as Haber)
        }
        bolumdekiHaberSayisi = [0:gosterilecekHaberler.count]
        self.tableView.reloadData()
    }
    
    
    
    
    func seciliKategorideAra(){
        let aramaKriteri = aramaKutusu.text,
        kategori = Kategori.objectsWhere("isim = %@", seciliKategori).firstObject() as Kategori
        gosterilecekHaberler = [:]
        bolumSayisi = 1
        bolumBasliklari = ["Arama Sonuclari"]
        var sorguSeti: [NSPredicate] = [],
        haberler = Haber.objectsWithPredicate(NSPredicate(format:"baslik CONTAINS[c] %@ or ozet CONTAINS[c] %@", aramaKriteri, aramaKriteri)!)
        for kaynak in kategori.kaynaklar {
            sorguSeti.append(NSPredicate(format:"kaynak = %@", kaynak)!)
        }
        haberler = haberler.objectsWithPredicate(NSCompoundPredicate.orPredicateWithSubpredicates(sorguSeti)).sortedResultsUsingProperty("tarih", ascending: true)
        for hid in 0 ..< haberler.count{
            gosterilecekHaberler["0.\(hid)"] =  (haberler.objectAtIndex(UInt(hid)) as Haber)
        }
        bolumdekiHaberSayisi = [0:gosterilecekHaberler.count]
        self.tableView.reloadData()
    }
    
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        switch seciliKategori{
        case "Favoriler":
            favorileriGoster()
        default:
            seciliKategorideAra()
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "haber_goster" || segue.identifier == "haber_goster2"{
            if let path = tableView.indexPathForSelectedRow(){
                let viewController = segue.destinationViewController as WebViewController
                viewController.haber = gosterilecekHaberler["\(path.section).\(path.row)"]
//                navigationController?.setViewControllers([viewController], animated: true)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if bolumSayisi == 1{
            return 0
        }else{
            return 20
        }
    }
    
    
    
    func haberGorselleriniIndir(){
        for (id, haber)  in gosterilecekHaberler{
            if haber.gorsel == "" && haber.gorselurl != ""{
                var gorselAdi = NSUUID().UUIDString
                var haberURL = haber.url
                var gorselYerelYol = dokumanlarDiziniYolu.stringByAppendingPathComponent(gorselAdi)
                if !dosyaYoneticisi.fileExistsAtPath(gorselYerelYol) {
                    let url = NSURL(string: haber.gorselurl)!
                    NSURLSession.sharedSession().downloadTaskWithURL(url, {
                        (yol, response, error) in
                        if yol != nil{
                            if (self.dosyaYoneticisi.copyItemAtPath(yol.path!, toPath:gorselYerelYol, error:nil)) {
//                                println("Dosya basariyla kaydedildi")
                                let rlm = RLMRealm.defaultRealm()
                                rlm.transactionWithBlock() {
                                    (Haber.objectsWhere("url = %@", haberURL).firstObject() as Haber).gorsel = gorselAdi
                                }
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.tableView.reloadData()
                                }
                            }
//                            else {
//                                println("Dosya kaydedilemedi!")
//                            }
                        }
                        
                    }).resume()
                }
                
            }
        }
        
    }
    

    
}
