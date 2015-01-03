//
//  KategoriViewController.swift
//  Ve Simdi Haberler
//
//  Created by Evren Esat Ozkan on 22/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm


//protocol KategoriViewDelegate {
//    func reloadData()
//
//}

class KategoriViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    let realm = RLMRealm.defaultRealm(),
        belgelerDizini = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    var kategoriler: RLMResults!

    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        collectionView!.dataSource = self
        collectionView!.delegate = self
        title = "Ve Şimdi Haberler"
        kategoriEkraniniYenile()
    }
    
    
    func kategoriEkraniniYenile(){
        self.kategoriler = Kategori.allObjects()
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(kategoriler.count)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let hucre = collectionView.dequeueReusableCellWithReuseIdentifier("Hucre", forIndexPath: indexPath) as UICollectionViewCell,
        tamamSimgesi = hucre.contentView.viewWithTag(200) as UIImageView,
        kategori = kategoriler.objectAtIndex(UInt(indexPath.row)) as Kategori,
        kategoriEtiketi = hucre.contentView.viewWithTag(300) as UILabel,
        kategoriGorseli = hucre.contentView.viewWithTag(100) as UIImageView
        kategoriEtiketi.text = kategori.isim
        
        
        tamamSimgesi.hidden = !kategori.secili
        kategoriGorseli.image = UIImage(contentsOfFile:"\(belgelerDizini)/\(kategori.gorsel)")
        return hucre
    }
    

     func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!)
    {
        let hucre = collectionView.cellForItemAtIndexPath(indexPath)! as UICollectionViewCell,
            tamamSimgesi = hucre.contentView.viewWithTag(200) as UIImageView,
            secilenKategori = kategoriler.objectAtIndex(UInt(indexPath.row)) as Kategori
        
        realm.transactionWithBlock() {
            secilenKategori.secili = (secilenKategori.secili == true) ? false : true
        }
        if secilenKategori.secili && secilenKategori.kaynaklar[0].haberler.count == 0{
            //TODO kategoriGuncelle
            kategoriGuncelle(kategori: secilenKategori)
        }
        tamamSimgesi.hidden = !tamamSimgesi.hidden
        secimVarsaMenuDugmeleriniGoster()
        
        //TODO menu reloadData
        self.navigationController?.sideMenuController()?.sideMenu?.menuTableViewController?.tableView.reloadData()
        
    }
    
    func secimVarsaMenuDugmeleriniGoster(){
        
        if Kategori.objectsWhere("secili = true").count > 0{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .Plain, target: self.navigationController?.sideMenuController()?.sideMenu, action: "toggleMenu")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tamam", style: .Plain, target: self.navigationController?.sideMenuController()?.sideMenu, action: "toggleMenu")
        }else{
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
