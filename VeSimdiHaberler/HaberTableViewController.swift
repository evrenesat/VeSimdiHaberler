//
//  HaberTableViewController.swift
//  VeSimdiHaberler
//
//  Created by Evren Esat Ozkan on 30/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm

class HaberTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var aramaKutusu: UISearchBar!
    var secili_kategori = "",
    bolumBasliklari: [String] = [],
    bolumSayisi = 0,
    gosterilecekHaberler: [String:Haber] = [:],
    bolumdekiHaberSayisi: [Int:Int] = [:]
    
    let dokumanlarDiziniYolu = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString,
    dosyaYoneticisi = NSFileManager.defaultManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aramaKutusu.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .Plain, target: self.navigationController, action: "toggleMenu")
        switch secili_kategori{
        case "":
            haberOzetleriniHazirla()
            aramaKutusu.hidden = true
            aramaKutusu.frame = CGRectMake(0,0,0,0)
        case "Favoriler":
            self.favorileriGoster()
        default:
            kategoridekiHaberleriHazirla()
        }
        haberGorselleriniIndir()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        switch secili_kategori{
        case "Favoriler":
            favorileriGoster()
        default:
            kategorideAra()
        }
        
    }
    
    func favorileriGoster(){
        gosterilecekHaberler = [:]
        self.navigationItem.title = "Favoriler"
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
    
    
    
    func kategorideAra(){
        let aramaKriteri = aramaKutusu.text
        gosterilecekHaberler = [:]
        let kategori = Kategori.objectsWhere("isim = %@", secili_kategori).firstObject() as Kategori
        self.navigationItem.title = secili_kategori
        bolumSayisi = 1
        bolumBasliklari = ["Arama Sonuclari"]
        var sorguSeti: [NSPredicate] = []
        var haberler = Haber.objectsWithPredicate(NSPredicate(format:"baslik CONTAINS[c] %@ or ozet CONTAINS[c] %@", aramaKriteri, aramaKriteri)!)
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
    
    
    func haberOzetleriniHazirla(){
        gosterilecekHaberler = [:]
        let kategori_set = Kategori.objectsWhere("secili =true")
        self.title = "Ve Şimdi Haberler"
        bolumSayisi = Int(kategori_set.count)
        for katID in 0 ..< kategori_set.count{
            var kid = Int(katID)
            var kategori = kategori_set.objectAtIndex(katID) as Kategori
            bolumBasliklari.append(kategori.isim)
            bolumdekiHaberSayisi[kid] = 0
            for kaynakID in 0 ..< kategori.kaynaklar.count {
                var kaynak = kategori.kaynaklar[kaynakID]
                for hid in 0 ..< Int(kaynak.haberler.count > 4 ? 4 : kaynak.haberler.count){
                    bolumdekiHaberSayisi[kid]! += 1
                    gosterilecekHaberler["\(kid).\(bolumdekiHaberSayisi[kid]! - 1)"] = kaynak.haberler[hid]
                }
            }
        }
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        var haber = gosterilecekHaberler["\(indexPath.section).\(indexPath.row)"]!
        var cell: UITableViewCell!
        if haber.gorsel != "" {
            cell = tableView.dequeueReusableCellWithIdentifier("HaberHucresi2", forIndexPath: indexPath) as UITableViewCell
            cell.indentationLevel  = 3
            cell.indentationWidth = 20
            var iview = UIImageView(image: UIImage(contentsOfFile:"\(dokumanlarDiziniYolu)/\(haber.gorsel)"))
            iview.frame = CGRectMake(4, 4, 50, 50)
            cell.contentView.addSubview(iview)
//            cell.imageView?.image = UIImage(contentsOfFile:"\(dokumanlarDiziniYolu)/\(haber.gorsel)")
//            cell.imageView?.frame = CGRectMake(4, 4, 50, 50)
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("HaberHucresi", forIndexPath: indexPath) as UITableViewCell
            cell.imageView?.image = nil
        }
        cell.textLabel?.text = haber.baslik
        
        cell.detailTextLabel?.text = haber.ozet
        return cell
    }
    
    func haberGorselleriniIndir(){
        //        func gorseliKaydet(dosya_path: String, yol: String){
        // gecici dizine indirdigimiz gorseli uygulamamizin Document dizinine kopyaliyoruz.
        
        //        }
        
        //        func gorseliIndir(image_name: String){
        // gorsel Document dizinimizde zaten mevcut degilse, sunucudan indiriyoruz.
        for (id, haber)  in gosterilecekHaberler{
            if haber.gorsel == "" && haber.gorselurl != ""{
                var image_name = NSUUID().UUIDString
                var haberUrl = haber.url
                var dosya_path = dokumanlarDiziniYolu.stringByAppendingPathComponent(image_name)
                if(!dosyaYoneticisi.fileExistsAtPath(dosya_path)) {
                    let url = NSURL(string: haber.gorselurl)!
                    NSURLSession.sharedSession().downloadTaskWithURL(url, {
                        (yol, response, error) in
                        if yol != nil{
                        if (self.dosyaYoneticisi.copyItemAtPath(yol.path!, toPath:dosya_path, error:nil)) {
                            println("Dosya basariyla kaydedildi")
                            let rlm = RLMRealm.defaultRealm()
                            rlm.transactionWithBlock() {
                                (Haber.objectsWhere("url = %@", haberUrl).firstObject() as Haber).gorsel = image_name
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                                return
                            }
                            //
                        }else {
                            println("Dosya kaydedilemedi!")
                        }
                        }
                        
                    }).resume()
                }
                
            }
        }
        
    }
    
    func kategoridekiHaberleriHazirla(){
        gosterilecekHaberler = [:]
        let kategori = Kategori.objectsWhere("isim = %@", secili_kategori).firstObject() as Kategori
        self.navigationItem.title = secili_kategori
        bolumSayisi = kategori.kaynaklar.count
        for kid in 0 ..< bolumSayisi {
            var kaynak = kategori.kaynaklar[kid]
            bolumBasliklari.append(kaynak.isim)
            var haberler  = kaynak.haberler
            var filtrelenmisHaberler: RLMResults!
            bolumdekiHaberSayisi[kid] = kaynak.haberler.count > 10 ? 10 : kaynak.haberler.count
            for hid in 0 ..< bolumdekiHaberSayisi[kid]!{
                gosterilecekHaberler["\(kid).\(hid)"] =  haberler[hid]
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "haber_goster" || segue.identifier == "haber_goster2"{
            if let path = tableView.indexPathForSelectedRow(){
                let viewController = segue.destinationViewController as PostViewController
                //                let haber  =
                //                viewController.haber = Haber.objectsWhere("url = %@", haber["url"]!).firstObject() as Haber
                viewController.haber = gosterilecekHaberler["\(path.section).\(path.row)"]
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
    
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return bolumSayisi
    }
    


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bolumdekiHaberSayisi[section]!
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return bolumBasliklari[section]
    }
    
}
