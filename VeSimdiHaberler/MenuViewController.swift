//
//  MenuViewController.swift
//  Ve Simdi Haberler
//
//  Created by Evren Esat Ozkan on 30/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm

class MenuTableViewKontrolcusu: UITableViewController {
    var seciliMenuOgesi : Int = 0,
        menuSatirSayisi = 0
    let realm = RLMRealm.defaultRealm(),
        sabitMenuOgesiSayisi = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // menüyü oluşturan tableview'ın görünüşünü özelleştiriyoruz.
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        let kategoriler = Kategori.objectsWhere("secili = true")
        menuSatirSayisi = Int(kategoriler.count) + sabitMenuOgesiSayisi
        return menuSatirSayisi
    }
    
    func yeniHucreOlustur(hucreAdi: String = "HUCRE") -> UITableViewCell{
        let hucre = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: hucreAdi)
        hucre.backgroundColor = UIColor.clearColor()
        hucre.textLabel!.textColor = UIColor.darkGrayColor()
        
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 220, hucre.frame.size.width, hucre.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        hucre.selectedBackgroundView = selectedBackgroundView
        
        hucre.indentationLevel  = 1
        hucre.indentationWidth = 20
        return hucre
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kategoriler = Kategori.objectsWhere("secili = true")
        let hacreAdi = "HUCRE"
        var hucre = tableView.dequeueReusableCellWithIdentifier(hacreAdi) as? UITableViewCell
        if (hucre == nil) {
            hucre = yeniHucreOlustur(hucreAdi: hacreAdi)
        }
        if indexPath.row < menuSatirSayisi - sabitMenuOgesiSayisi{
            // kategorileri menuye ekliyoruz
            let kategori = kategoriler.objectAtIndex(UInt(indexPath.row)) as Kategori
            hucre!.textLabel!.text =  kategori.isim
            return hucre!
        }else{
            // menunun sonunda sabitMenuOgesiSayisi kadarlık kısmını sabit menülerimiz için ayırdık.
            return menuOgeleriniEkle(indexPath.row)
        }
    }
    
    func menuOgeleriniEkle(row: Int) -> UITableViewCell{
        let hacreAdi = "SIMGELI_HUCRE"
        var hucre = tableView.dequeueReusableCellWithIdentifier(hacreAdi) as? UITableViewCell
        if hucre == nil{
            hucre = yeniHucreOlustur(hucreAdi: hacreAdi)
        }
        var simge: UIImage!
        hucre!.textLabel?.textColor = UIColor.blackColor()
        switch row{
        case menuSatirSayisi - 2:
            hucre!.textLabel!.text = "Favoriler"
            simge = UIImage(named: "star")
        case menuSatirSayisi - 1:
            hucre!.textLabel!.text = "Kategoriler"
            simge = UIImage(named: "home")
        default: break
        }
        var simgeKutusu = UIImageView(image: simge)
        simgeKutusu.frame = CGRectMake(5, 12, simgeKutusu.frame.size.width, simgeKutusu.frame.size.height)
        hucre!.contentView.addSubview(simgeKutusu)
        return hucre!
    }
    

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        

        seciliMenuOgesi = indexPath.row
        let hucre = tableView.cellForRowAtIndexPath(indexPath),
            anaStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        if indexPath.row == menuSatirSayisi - 1{
            // kategoriler dugmesi basildi, "kategori_secimi" viewini etkinlestirip ekrana getiriyoruz.
            let kategoriSecimEkrani = anaStoryboard.instantiateViewControllerWithIdentifier("kategori_secimi") as KategoriViewController
            sideMenuController()?.setContentViewController(kategoriSecimEkrani)
        }else{
            // bir kategori ya da "Favoriler" secildiginde "haberler" viewini
            let haberListViewController = anaStoryboard.instantiateViewControllerWithIdentifier("haberler") as HaberTableViewController
            haberListViewController.seciliKategori = hucre!.textLabel!.text!
            sideMenuController()?.setContentViewController(haberListViewController)
        }
    }
}
