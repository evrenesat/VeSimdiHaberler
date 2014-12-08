//
//  ViewController.swift
//  News App 3
//
//  Created by Evren Esat Ozkan on 17/11/14.
//  Copyright (c) 2014 Evren Esat Ozkan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {

        LoadBaseData()
//        let vc : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("kategori_secimi") as UIViewController;
//        self.navigationController?.pushViewController(vc, animated:true)
//        self.presentViewController(vc, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

