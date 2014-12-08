//
//  RootNavigationViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class ENSideMenuNavigationController: UINavigationController, ENSideMenuDelegate, ENSideMenuProtocol {
    
    internal var sideMenu : ENSideMenu?
    internal var sideMenuAnimationType : ENSideMenuAnimation = .Default
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu?.delegate = self
    }
    
    init( menuTableViewController: UITableViewController, contentViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        if (contentViewController != nil) {
            self.viewControllers = [contentViewController!]
        }

        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: menuTableViewController, menuPosition:.Left)
        
        view.bringSubviewToFront(navigationBar)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleMenu(){
        self.sideMenu?.toggleMenu()
    }
    
    // MARK: - Navigation
    func setContentViewController(contentViewController: UIViewController) {
        self.sideMenu?.toggleMenu()
        switch sideMenuAnimationType {
        case .None:
            self.viewControllers = [contentViewController]
            break
        default:
            let menuIcon = UIImage(named: "menu_icon")
            let menuButton = UIBarButtonItem(image: menuIcon, style: .Plain, target: self, action: "toggleMenu")
            contentViewController.navigationItem.leftBarButtonItem = menuButton
            self.pushViewController(contentViewController, animated: true)
            break
        }
        
    }

}
