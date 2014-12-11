//
//  KategoriViewController.swift
//  News App 3
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
        cellId = "CollectionViewCell",
        documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    var kategori_set: RLMResults!

    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {

        super.viewDidLoad()
        
        collectionView!.dataSource = self
        collectionView!.delegate = self
        self.title = "Ve Şimdi Haberler"
        reloadData()

    }
    
    func secimVarsaMenuDugmeleriniGoster(){
        self.navigationItem.hidesBackButton = true
        if Kategori.objectsWhere("secili = true").count > 0{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"menu"), style: .Plain, target: self.navigationController, action: "toggleMenu")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tamam", style: .Plain, target: self.navigationController, action: "toggleMenu")
        }else{
            
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            
            
        }
        
    }
   
    func reloadData(){
        self.kategori_set = Kategori.allObjects()
        self.collectionView.reloadData()


    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(kategori_set.count)
    }
     func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)! as UICollectionViewCell,
            okImage = cell.contentView.viewWithTag(200) as UIImageView,
            kategori = kategori_set.objectAtIndex(UInt(indexPath.row)) as Kategori
        
        realm.transactionWithBlock() {
            kategori.secili = (kategori.secili == true) ? false : true
            
        }
        if kategori.secili && kategori.kaynaklar[0].haberler.count == 0{
            kategoriGuncelle(kategori: kategori)
        }
        okImage.hidden = !okImage.hidden
        
        secimVarsaMenuDugmeleriniGoster()
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as UICollectionViewCell,
            okImage = cell.contentView.viewWithTag(200) as UIImageView,
            kategori = kategori_set.objectAtIndex(UInt(indexPath.row)) as Kategori,
            label = cell.contentView.viewWithTag(300) as UILabel,
            imageView = cell.contentView.viewWithTag(100) as UIImageView
        label.text = kategori.isim
        

        okImage.hidden = !kategori.secili
        imageView.image = UIImage(contentsOfFile:"\(documentsPath)/\(kategori.gorsel)")
        return cell
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
