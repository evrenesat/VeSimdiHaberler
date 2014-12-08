//
//  AppDelegate.swift
//  News App 3
//
//  Created by Evren Esat Ozkan on 17/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //var newsNavigationController: ENSideMenuNavigationController?
    var newsNavigationController: ENSideMenuNavigationController!
    var menuTableViewCont: NewsMenuTableViewController?
    var haberler: HaberTableViewController?
    //var acilis_ekrani: UIViewController!
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        menuTableViewCont = NewsMenuTableViewController()
        //
        
        let realm = RLMRealm.defaultRealm()
        println(RLMRealm.defaultRealm().path)
        
        
        //
//        realm.transactionWithBlock() {realm.deleteAllObjects()}
        //
        
        newsNavigationController = ENSideMenuNavigationController(menuTableViewController: menuTableViewCont!, contentViewController:nil)
        //        var testViewController: UIViewController = UIViewController()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        mainStoryboard.instantiateViewControllerWithIdentifier("kategori_secimi")
        
        if Kategori.objectsWhere("secili = true").count > 0{
            var acilis_ekrani = mainStoryboard.instantiateViewControllerWithIdentifier("haberler") as HaberTableViewController
            self.newsNavigationController!.pushViewController(acilis_ekrani, animated: false)
            //            acilis_ekrani.tableView.reloadData()
            loadBaseData(uiv: nil)
        }
        else{
            var acilis_ekrani = mainStoryboard.instantiateViewControllerWithIdentifier("kategori_secimi") as KategoriViewController
            
            self.newsNavigationController!.pushViewController(acilis_ekrani, animated: false)
            loadBaseData(uiv: acilis_ekrani)
        }
        
        
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window!.rootViewController = newsNavigationController
        
        self.window!.backgroundColor = UIColor.whiteColor()
        
        
        self.window!.makeKeyAndVisible()
        
        
        haberleriGuncelle()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

