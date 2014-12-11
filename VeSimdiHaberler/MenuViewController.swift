//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit
import Realm

class MenuTableViewKontrolcusu: UITableViewController {
    var selectedMenuItem : Int = 0
    let realm = RLMRealm.defaultRealm()
    var tag = 500
    var kategori_set = Kategori.objectsWhere("secili = true")
    var menuSatirSayisi = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        //        tableView.tag = 500
        //        self.tableView. //addSubview(UIButton())
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        var kategori_set = Kategori.objectsWhere("secili = true")
        menuSatirSayisi = Int(kategori_set.count) + 2
        return menuSatirSayisi
    }
    
    func yeniHucreOlustur(hucreAdi: String = "CELL") -> UITableViewCell{
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: hucreAdi)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.darkGrayColor()
        
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 220, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.indentationLevel  = 1
        cell.indentationWidth = 20
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kategori_set = Kategori.objectsWhere("secili = true")
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        if (cell == nil) {
            cell = yeniHucreOlustur()
        }
        if indexPath.row < menuSatirSayisi - 2{
            let kategori = kategori_set.objectAtIndex(UInt(indexPath.row)) as Kategori
            cell!.textLabel!.text =  kategori.isim
            return cell!
        }else{
            return menuOgeleriniEkle(indexPath.row)
        }
    }
    
    func menuOgeleriniEkle(row: Int) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("MCELL") as? UITableViewCell
        if cell == nil{
            cell = yeniHucreOlustur(hucreAdi: "MCELL")
        }
        var gorsel: UIImage!
        switch row{
        case menuSatirSayisi - 2:
            cell!.textLabel!.text = "Favoriler"
            cell!.textLabel
            gorsel = UIImage(named: "star")
        case menuSatirSayisi - 1:
            cell!.textLabel!.text = "Kategoriler"
            gorsel = UIImage(named: "home")
        default: break
        }
        var iview = UIImageView(image: gorsel)
        iview.frame = CGRectMake(5, 12, iview.frame.size.width, iview.frame.size.height)
        cell!.contentView.addSubview(iview)
        return cell!
    }
    

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("did select row: \(indexPath.row)")
        
        //        if (indexPath.row == selectedMenuItem) {
        //            return
        //        }
        selectedMenuItem = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath),
            anaStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        if indexPath.row == menuSatirSayisi - 1{
            let kategoriSecimEkrani = anaStoryboard.instantiateViewControllerWithIdentifier("kategori_secimi") as KategoriViewController
            sideMenuController()?.setContentViewController(kategoriSecimEkrani)
        }else{
            
            let haberListViewController = anaStoryboard.instantiateViewControllerWithIdentifier("haberler") as HaberTableViewController
            haberListViewController.secili_kategori = cell!.textLabel!.text!
            sideMenuController()?.setContentViewController(haberListViewController)
        }
        
        
        
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
