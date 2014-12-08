//
//  KategoriViewController.swift
//  News App 3
//
//  Created by Evren Esat Ozkan on 22/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm

class KategoriViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {

    let realm = RLMRealm.defaultRealm(),
        kategori_set = Kategori.allObjects(),
        cellId = "CollectionViewCell",
        documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func kategoriSecimleriniKaydet(sender: AnyObject) {
    }

    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        NSLog("Navigation Controller %@",self.navigationController ?? "Nope")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
//        layout.itemSize = CGSize(width: 90, height: 90)
//        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
//        collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
//        collectionView!.backgroundColor = UIColor.whiteColor()
//        self.view.addSubview(collectionView!)
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
        okImage.hidden = !okImage.hidden
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as UICollectionViewCell,
            okImage = cell.contentView.viewWithTag(200) as UIImageView,
            kategori = kategori_set.objectAtIndex(UInt(indexPath.row)) as Kategori,
            label = cell.contentView.viewWithTag(300) as UILabel,
            imageView = cell.contentView.viewWithTag(100) as UIImageView
        label.text = kategori.isim
        okImage.hidden = !kategori.secili
        imageView.image = UIImage(contentsOfFile:"\(documentsPath)/\(kategori.gorsel).png")
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
